/**
 * Seeds exactly 10 campus events (5 inter + 5 intra) across colleges.
 * Usage: node scripts/seed-student-events.js
 *
 * Images live in frontend/assets/images/events/ — see filenames below.
 */
const mongoose = require("mongoose");

const MONGODB_URL =
  process.env.MONGODB_URL || "mongodb://127.0.0.1:27017/unisphere";

const HERALD = "Herald College Kathmandu (University of Wolverhampton)";
const ISLINGTON = "Islington College (London Metropolitan University)";
const SOFTWARICA =
  "Softwarica College of IT & E-Commerce (Coventry University)";
const BRITISH = "The British College (UWE Bristol / Leeds Beckett)";
const NAMI = "NAMI College (University of Northampton)";
const ISMT = "ISMT College (University of Sunderland)";
const PATAN =
  "Patan College for Professional Studies (PCPS - University of Bedfordshire)";
const TEXAS = "Texas College of Management and IT (Lincoln University)";

/** imageFile = exact filename in frontend/assets/images/events/ */
const events = [
  {
    title: "College Fest 2026",
    description: "Stalls, performances, and campus clubs in one big fest.",
    date: new Date("2026-08-15T10:00:00.000Z"),
    location: "Islington Main Ground",
    category: "Cultural",
    eventType: "Intercollegiate",
    college: ISLINGTON,
    capacity: 400,
    cashPrize: "Trophies + Goodies",
    imageFile: "collegeFest.jpeg",
  },
  {
    title: "Kathmandu Hackathon",
    description: "24-hour coding sprint — build, pitch, and win.",
    date: new Date("2026-08-22T09:00:00.000Z"),
    location: "Softwarica Innovation Lab",
    category: "Technical",
    eventType: "Intercollegiate",
    college: SOFTWARICA,
    capacity: 80,
    cashPrize: "NPR 50,000",
    imageFile: "hackathon.jpeg",
  },
  {
    title: "Campus Job Fair",
    description: "Meet recruiters and drop your CV on campus.",
    date: new Date("2026-09-05T05:00:00.000Z"),
    location: "British College Convention Hall",
    category: "Management",
    eventType: "Intercollegiate",
    college: BRITISH,
    capacity: 300,
    cashPrize: "Internship + referral packages",
    imageFile: "jobfair.jpg",
  },
  {
    title: "Literary Meet & Open Mic",
    description: "Poetry, stories, and open mic across colleges.",
    date: new Date("2026-08-16T16:00:00.000Z"),
    location: "NAMI Amphitheatre",
    category: "Literary",
    eventType: "Intercollegiate",
    college: NAMI,
    capacity: 90,
    cashPrize: "NPR 8,000",
    imageFile: "literary.jpeg",
  },
  {
    title: "Intercollege Sports Meet",
    description: "Football, basketball, and athletics for the cup.",
    date: new Date("2026-09-12T07:00:00.000Z"),
    location: "Patan Sports Complex",
    category: "Sports",
    eventType: "Intercollegiate",
    college: PATAN,
    capacity: 250,
    cashPrize: "Trophy + Medals",
    imageFile: "sports.jpeg",
  },
  {
    title: "Startup Pitch Night",
    description: "Pitch your idea to mentors — Herald only.",
    date: new Date("2026-09-01T17:00:00.000Z"),
    location: "Herald Seminar Hall",
    category: "Management",
    eventType: "Intracollegiate",
    college: HERALD,
    capacity: 60,
    cashPrize: "Incubation support",
    imageFile: "management.jpeg",
  },
  {
    title: "Live Music Night",
    description: "Bands and open stage at the Herald courtyard.",
    date: new Date("2026-08-08T18:30:00.000Z"),
    location: "Herald College Courtyard",
    category: "Cultural",
    eventType: "Intracollegiate",
    college: HERALD,
    capacity: 180,
    cashPrize: "NPR 5,000 best act",
    imageFile: "music.jpg",
  },
  {
    title: "Pottery Workshop",
    description: "Hands-on clay session — make something to take home.",
    date: new Date("2026-08-20T11:00:00.000Z"),
    location: "Softwarica Creative Studio",
    category: "Workshop",
    eventType: "Intracollegiate",
    college: SOFTWARICA,
    capacity: 35,
    imageFile: "pottery_workshop.jpeg",
  },
  {
    title: "Speak — Campus Forum",
    description: "Bold talks and open debate for Herald students.",
    date: new Date("2026-08-01T04:15:00.000Z"),
    location: "TC Hall",
    category: "Others",
    eventType: "Intracollegiate",
    college: HERALD,
    capacity: 30,
    imageFile: "speak.jpg",
  },
  {
    title: "Talent Show",
    description: "Sing, dance, or act — show your campus talent.",
    date: new Date("2026-08-28T17:00:00.000Z"),
    location: "Texas College Auditorium",
    category: "Cultural",
    eventType: "Intracollegiate",
    college: TEXAS,
    capacity: 120,
    cashPrize: "NPR 10,000",
    imageFile: "talent_show.jpeg",
  },
];

(async () => {
  await mongoose.connect(MONGODB_URL);
  const db = mongoose.connection.db;
  const users = db.collection("users");
  const eventsCol = db.collection("events");

  let admin = await users.findOne({ role: "admin" });
  if (!admin) admin = await users.findOne({});
  if (!admin) throw new Error("No users found — register an account first.");

  const organizerId = admin._id;
  let inserted = 0;
  let updated = 0;
  const titles = events.map((e) => e.title);

  for (const evt of events) {
    const { imageFile, ...doc } = evt;
    const existing = await eventsCol.findOne({ title: evt.title });
    if (existing) {
      await eventsCol.updateOne(
        { _id: existing._id },
        {
          $set: {
            ...doc,
            updatedAt: new Date(),
          },
        }
      );
      updated += 1;
      console.log(`  ~ ${evt.eventType.padEnd(16)} ${evt.title}  →  ${imageFile}`);
    } else {
      await eventsCol.insertOne({
        ...doc,
        registeredCount: 0,
        organizer: organizerId,
        createdAt: new Date(),
        updatedAt: new Date(),
      });
      inserted += 1;
      console.log(`  ✓ ${evt.eventType.padEnd(16)} ${evt.title}  →  ${imageFile}`);
    }
  }

  // Drop demo events that are no longer in the set (keep registrations for remaining).
  const removed = await eventsCol.deleteMany({ title: { $nin: titles } });

  console.log(
    JSON.stringify(
      {
        organizer: admin.email,
        inserted,
        updated,
        removedOther: removed.deletedCount,
        total: await eventsCol.countDocuments(),
        note: "Intra events only show to students of that college; Inter show to all.",
      },
      null,
      2
    )
  );
  await mongoose.disconnect();
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
