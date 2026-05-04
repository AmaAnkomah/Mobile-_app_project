$p = 'plugins/firebase_core/windows/CMakeLists.txt'
$c = Get-Content $p -Raw

# 1. Update minimum requirement if not already set
if ($c -notmatch 'cmake_minimum_required\(VERSION 3.14\)') {
    $c = $c -replace 'cmake_minimum_required\(VERSION [0-9.]+\)', 'cmake_minimum_required(VERSION 3.14)'
}

# 2. Add target property safety checks if missing
if ($c -notmatch 'if\(TARGET \${firebase_lib}\)') {
    $targetPatch = 'foreach(firebase_lib IN ITEMS ${FIREBASE_RELEASE_PATH_LIBS})
    if(TARGET ${firebase_lib})
        get_target_property(firebase_lib_path ${firebase_lib} IMPORTED_LOCATION)
        if(firebase_lib_path)
            string(REPLACE "Debug" "Release" firebase_lib_release_path "${firebase_lib_path}")
            set_target_properties(${firebase_lib} PROPERTIES
              IMPORTED_LOCATION_DEBUG "${firebase_lib_path}"
              IMPORTED_LOCATION_RELEASE "${firebase_lib_release_path}"
            )
        endif()
    endif()
endforeach()'
    $c = $c -replace 'foreach\(firebase_lib IN ITEMS \${FIREBASE_RELEASE_PATH_LIBS}\)[\s\S]+?endforeach\(\)', $targetPatch
}

# 3. Add SDK version patch for extracted SDK (Targets 3.15.2 patterns)
# Use a non-destructive read/replace/write cycle in CMake
if ($c -active -notmatch 'file\(READ "\${FIREBASE_CPP_SDK_DIR}/CMakeLists.txt" _cmake_content\)') {
    $extractionPattern = 'file\(ARCHIVE_EXTRACT INPUT \${firebase_sdk_filename}\s+DESTINATION \${extracted_path}\)'
    
    $patchLines = @(
        '        file(ARCHIVE_EXTRACT INPUT ${firebase_sdk_filename} DESTINATION ${extracted_path})',
        '        # Non-destructive patch for Firebase SDK CMakeLists.txt VERSION 3.1 deprecation',
        '        file(READ "${FIREBASE_CPP_SDK_DIR}/CMakeLists.txt" _cmake_content)',
        '        string(REPLACE "cmake_minimum_required(VERSION 3.1)" "cmake_minimum_required(VERSION 3.14)" _cmake_content "${_cmake_content}")',
        '        file(WRITE "${FIREBASE_CPP_SDK_DIR}/CMakeLists.txt" "${_cmake_content}")'
    )
    $patch = [string]::Join("`r`n", $patchLines)
    
    $c = [Regex]::Replace($c, $extractionPattern, $patch)
}

$c | Out-File $p -Encoding utf8
Write-Host "Successfully patched $p"
