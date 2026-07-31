import { Router } from "express";
import { SecurityController } from "../controllers/security.controller";
import { LoginHistoryMongoRepository } from "../repositories/login-history.repository";
import { UserMongoRepository } from "../repositories/user.repository";
import { SecurityService } from "../services/security.service";
import { authorizedMiddleware } from "../middlewares/authorized.middleware";

const userRepository = new UserMongoRepository();
const loginHistoryRepository = new LoginHistoryMongoRepository();
const securityService = new SecurityService(userRepository, loginHistoryRepository);
const securityController = new SecurityController(securityService);

const router = Router();

router.use(authorizedMiddleware);

/** GET /api/v1/auth/security/login-history — Bearer. Returns caller's login history. */
router.get("/login-history", securityController.getLoginHistory);

/** GET /api/v1/auth/security/sessions — Bearer. Returns active sessions + loginAlertsEnabled. */
router.get("/sessions", securityController.getSessions);

/** DELETE /api/v1/auth/security/sessions/:sessionId — Bearer. Revokes a session (404 if missing). */
router.delete("/sessions/:sessionId", securityController.revokeSession);

/** POST /api/v1/auth/security/logout-all — Bearer. Revokes all sessions for the caller. */
router.post("/logout-all", securityController.logoutAllDevices);

/** POST /api/v1/auth/security/verify-password — Bearer. Body: password. Confirms password. */
router.post("/verify-password", securityController.verifyPassword);

/** PUT /api/v1/auth/security/settings — Bearer. Body: loginAlertsEnabled (boolean). */
router.put("/settings", securityController.updateSettings);

export default router;
