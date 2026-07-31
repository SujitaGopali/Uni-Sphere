const mongoose = require("mongoose");

(async () => {
  await mongoose.connect("mongodb://127.0.0.1:27017/unisphere");
  const r = await mongoose.connection.db.collection("events").updateMany(
    { brochureImage: { $type: "string" } },
    { $unset: { brochureImage: "" } }
  );
  console.log("cleared brochures", r.modifiedCount);
  const count = await mongoose.connection.db.collection("events").countDocuments();
  console.log("events", count);
  await mongoose.disconnect();
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
