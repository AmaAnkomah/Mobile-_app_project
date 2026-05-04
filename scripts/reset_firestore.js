/**
 * reset_firestore.js
 * Wipes all courses & quizzes from Firestore and re-seeds them with
 * course-specific videos and quizzes.
 *
 * Run:  node reset_firestore.js
 */

import { initializeApp } from "firebase/app";
import {
  getFirestore,
  collection,
  getDocs,
  deleteDoc,
  addDoc,
  doc,
} from "firebase/firestore";

// ── Firebase config (from firebase_options.dart) ──────────────────────────
const firebaseConfig = {
  apiKey: "AIzaSyCoMYRyL-EosKdGU4mX0VoTYqIcPdZjQvE",
  authDomain: "learning-platform-b73b9.firebaseapp.com",
  projectId: "learning-platform-b73b9",
  storageBucket: "learning-platform-b73b9.firebasestorage.app",
  messagingSenderId: "962496895627",
  appId: "1:962496895627:web:d4b152e50c6530c69dd28e",
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// ── Course data (each course has its OWN unique video) ─────────────────────
const COURSES = [
  {
    title: "Flutter Mastery 2024",
    description: "Build beautiful mobile apps from scratch.",
    long_description:
      "This comprehensive course covers everything from Dart basics to advanced Flutter architecture. You will learn how to build production-ready apps with professional state management and clean architecture.",
    instructor_id: "demo_instructor_1",
    category: "Programming",
    thumbnail_url:
      "https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800",
    video_url:
      "https://www.youtube.com/watch?v=fq4N0hgOWzU",
  },
  {
    title: "UI/UX Design Principles",
    description: "Master the art of user-centric design.",
    long_description:
      "Learn how to create stunning interfaces that users love. We cover typography, color theory, spacing, and how to create interactive prototypes using Figma and Adobe XD.",
    instructor_id: "design_pro_2",
    category: "Design",
    thumbnail_url:
      "https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800",
    video_url:
      "https://www.youtube.com/watch?v=b_sQ9bMltGU",
  },
  {
    title: "Digital Marketing Strategies",
    description: "Grow your business online effectively.",
    long_description:
      "Master SEO, SEM, and social media marketing. Learn how to run successful campaigns on Google Ads and Facebook to drive conversions.",
    instructor_id: "marketing_guru_3",
    category: "Marketing",
    thumbnail_url:
      "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800",
    video_url:
      "https://www.youtube.com/watch?v=d_m5csmrf7I",
  },
  {
    title: "Business Management 101",
    description: "Core fundamentals for modern leaders.",
    long_description:
      "Develop leadership skills, understand financial statements, and learn strategic planning to manage successful teams and organizations.",
    instructor_id: "business_exec_4",
    category: "Business",
    thumbnail_url:
      "https://images.unsplash.com/photo-1507679799987-c73779587ccf?w=800",
    video_url:
      "https://www.youtube.com/watch?v=5F-6n_2XbOU",
  },
  {
    title: "Health & Wellness Coach",
    description: "Live a balanced and healthy lifestyle.",
    long_description:
      "Learn about nutrition, exercise science, and mental well-being to achieve your personal health goals or help others on their journey.",
    instructor_id: "fitness_expert_5",
    category: "Health",
    thumbnail_url:
      "https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800",
    video_url:
      "https://www.youtube.com/watch?v=vQ1D8L30R1w",
  },
];

// ── Per-course quiz questions (keyed by title keyword) ─────────────────────
const QUESTIONS_BY_KEYWORD = {
  Flutter: [
    {
      text: "What programming language is Flutter built with?",
      options: ["Java", "Kotlin", "Dart", "Swift"],
      correct_option_index: 2,
    },
    {
      text: "Which widget is used for layouts that DO NOT change over time?",
      options: ["StatefulWidget", "StatelessWidget", "InheritedWidget", "FutureBuilder"],
      correct_option_index: 1,
    },
    {
      text: "What is the command to create a new Flutter project?",
      options: ["flutter start myapp", "flutter create myapp", "flutter new myapp", "flutter init myapp"],
      correct_option_index: 1,
    },
    {
      text: "Which package is most commonly used for state management in Flutter?",
      options: ["Redux", "MobX", "Provider", "Riverpod"],
      correct_option_index: 2,
    },
  ],
  "UI/UX": [
    {
      text: "What does UX stand for?",
      options: ["User Execution", "User Experience", "Universal Exchange", "Unified Extension"],
      correct_option_index: 1,
    },
    {
      text: "Which tool is most commonly used for UI prototyping?",
      options: ["Photoshop", "Figma", "Illustrator", "Excel"],
      correct_option_index: 1,
    },
    {
      text: 'What is the "60-30-10" rule in design?',
      options: ["Font size ratio", "A color proportion rule", "Grid column ratio", "Spacing guideline"],
      correct_option_index: 1,
    },
    {
      text: 'What does "affordance" mean in UX design?',
      options: [
        "The price of a design tool",
        "A visual cue suggesting how to use an element",
        "The number of screens in an app",
        "A type of animation",
      ],
      correct_option_index: 1,
    },
  ],
  "Digital Marketing": [
    {
      text: "What does SEO stand for?",
      options: [
        "Social Engagement Optimization",
        "Search Engine Optimization",
        "Sales and Earnings Output",
        "System Exchange Operations",
      ],
      correct_option_index: 1,
    },
    {
      text: "Which metric measures the percentage of users who click an ad?",
      options: ["CPM", "ROI", "CTR", "CPA"],
      correct_option_index: 2,
    },
    {
      text: "What platform is best known for B2B digital marketing?",
      options: ["Instagram", "TikTok", "LinkedIn", "Pinterest"],
      correct_option_index: 2,
    },
    {
      text: 'What is a "conversion" in digital marketing?',
      options: [
        "Changing a logo",
        "A desired action completed by a user",
        "Switching ad platforms",
        "Translating content to another language",
      ],
      correct_option_index: 1,
    },
  ],
  "Business Management": [
    {
      text: "What does SWOT analysis stand for?",
      options: [
        "Sales, Workflow, Output, Target",
        "Strengths, Weaknesses, Opportunities, Threats",
        "Strategy, Work, Operations, Tools",
        "Systems, Wages, Output, Trends",
      ],
      correct_option_index: 1,
    },
    {
      text: "Which management style involves employees in decision-making?",
      options: ["Autocratic", "Laissez-faire", "Democratic", "Transactional"],
      correct_option_index: 2,
    },
    {
      text: "What does KPI stand for?",
      options: [
        "Key Performance Indicator",
        "Key Process Integration",
        "Knowledge and Productivity Index",
        "Key Program Input",
      ],
      correct_option_index: 0,
    },
    {
      text: "Which financial statement shows revenues and expenses over a period?",
      options: ["Balance Sheet", "Cash Flow Statement", "Income Statement", "Equity Report"],
      correct_option_index: 2,
    },
  ],
  Health: [
    {
      text: "How many hours of sleep are recommended for an adult per night?",
      options: ["4-5 hours", "6-7 hours", "7-9 hours", "10-12 hours"],
      correct_option_index: 2,
    },
    {
      text: "Which macronutrient is the body's primary source of energy?",
      options: ["Protein", "Fat", "Carbohydrates", "Vitamins"],
      correct_option_index: 2,
    },
    {
      text: "What does BMI stand for?",
      options: [
        "Body Metabolism Index",
        "Basic Muscle Intake",
        "Body Mass Index",
        "Bone Mineral Index",
      ],
      correct_option_index: 2,
    },
    {
      text: "How many minutes of moderate exercise per week does WHO recommend?",
      options: ["75 minutes", "150 minutes", "300 minutes", "60 minutes"],
      correct_option_index: 1,
    },
  ],
};

// ── Helpers ────────────────────────────────────────────────────────────────
async function deleteCollection(colName) {
  const snap = await getDocs(collection(db, colName));
  let count = 0;
  for (const d of snap.docs) {
    await deleteDoc(doc(db, colName, d.id));
    count++;
  }
  console.log(`  🗑  Deleted ${count} document(s) from '${colName}'`);
}

function getQuestionsForCourse(title) {
  for (const keyword of Object.keys(QUESTIONS_BY_KEYWORD)) {
    if (title.includes(keyword)) return QUESTIONS_BY_KEYWORD[keyword];
  }
  return []; // fallback (shouldn't happen with our 5 courses)
}

// ── Main ───────────────────────────────────────────────────────────────────
async function main() {
  console.log("\n🔄  Starting Firestore reset...\n");

  // 1. Delete old data
  console.log("Step 1: Deleting old data...");
  await deleteCollection("courses");
  await deleteCollection("quizzes");

  // 2. Seed courses
  console.log("\nStep 2: Seeding courses...");
  const insertedCourses = [];
  for (const course of COURSES) {
    const ref = await addDoc(collection(db, "courses"), course);
    insertedCourses.push({ id: ref.id, title: course.title });
    console.log(`  ✅  Added course: "${course.title}" (id: ${ref.id})`);
  }

  // 3. Seed quizzes
  console.log("\nStep 3: Seeding course-specific quizzes...");
  for (const { id, title } of insertedCourses) {
    const questions = getQuestionsForCourse(title);
    await addDoc(collection(db, "quizzes"), {
      course_id: id,
      questions,
    });
    console.log(`  ✅  Added quiz for: "${title}" (${questions.length} questions)`);
  }

  console.log("\n🎉  Done! Your Firestore now has fresh, course-specific data.");
  console.log("    Restart or refresh your Flutter app to see the changes.\n");
  process.exit(0);
}

main().catch((err) => {
  console.error("❌  Error:", err);
  process.exit(1);
});
