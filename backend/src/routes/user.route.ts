import { Router } from "express";
import { UserController } from "../controllers/user.controller";
import { UserMongoRepository } from "../repositories/user.repository";
import { LoginHistoryMongoRepository } from "../repositories/login-history.repository";
import { UserService } from "../services/user.service";
import { SecurityService } from "../services/security.service";
import { authorizedMiddleware } from "../middlewares/authorized.middleware";
import { uploadMiddleware } from "../middlewares/upload.middleware";
import securityRoutes from "./security.route";

const userRepository = new UserMongoRepository();
const loginHistoryRepository = new LoginHistoryMongoRepository();
const securityService = new SecurityService(userRepository, loginHistoryRepository);
const userService = new UserService(userRepository, loginHistoryRepository, securityService);
const userController = new UserController(userService);

const router = Router();

/** POST /api/v1/auth/register — Public. Body: name, email, username, password, etc. Returns 201 user. */
router.post("/register", userController.register);

/** POST /api/v1/auth/login — Public. Body: email, password. Returns JWT + user. */
router.post("/login", userController.login);

/** GET /api/v1/auth/whoami — Bearer. Returns current user or 401. */
router.get("/whoami", authorizedMiddleware, userController.whoami);

/** PUT /api/v1/auth/update — Bearer. Multipart profile fields + optional image. Returns updated user. */
router.put("/update", uploadMiddleware.single("profileImage"), authorizedMiddleware, userController.updateProfile);

/** POST /api/v1/auth/verify — Bearer. Body: idImage. Submits ID verification. */
router.post("/verify", authorizedMiddleware, userController.submitVerification);

/** Nested: /api/v1/auth/security/* */
router.use("/security", securityRoutes);

export default router;
