import app from "./src/app";
import { connectDatabase } from "./src/database/mongodb";
import { PORT } from "./src/configs/constant";

const startServer = async () => {
  await connectDatabase();
  app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
  });
};

startServer();
