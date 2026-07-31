import { Router } from "express";
import { LoginHistoryController } from "../controllers/login-history.controller";
import { authorizedMiddleware, adminMiddleware } from "../middlewares/authorized.middleware";

const router = Router();
const loginHistoryController = new LoginHistoryController();

router.use(authorizedMiddleware);
router.use(adminMiddleware);

/** GET /api/v1/admin/login-history — Admin. Query: page, limit. Returns paginated history. */
router.get("/", loginHistoryController.getAllLoginHistory);

/** GET /api/v1/admin/login-history/user/:id — Admin. Returns login history for a user. */
router.get("/user/:id", loginHistoryController.getUserLoginHistory);

export default router;
