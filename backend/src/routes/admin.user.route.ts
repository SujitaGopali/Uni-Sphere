import { Router } from "express";
import { AdminUserController } from "../controllers/admin.user.controller";
import { authorizedMiddleware, adminMiddleware } from "../middlewares/authorized.middleware";

const adminUserRoutes = Router();
const adminUserController = new AdminUserController();

adminUserRoutes.use(authorizedMiddleware);
adminUserRoutes.use(adminMiddleware);

/** GET /api/v1/admin/users — Admin. Query: page, limit, search. Returns paginated users. */
adminUserRoutes.get("/", adminUserController.getAllUsers);

// Static verification paths must be registered before "/:id" or "verifications" is treated as an id.
/** GET /api/v1/admin/users/verifications/pending — Admin. Returns pending ID verifications. */
adminUserRoutes.get("/verifications/pending", adminUserController.getPendingVerifications);

/** POST /api/v1/admin/users/verifications/:id/review — Admin. Body: approved (boolean). */
adminUserRoutes.post("/verifications/:id/review", adminUserController.reviewVerification);

/** GET /api/v1/admin/users/:id — Admin. Returns user or 404. */
adminUserRoutes.get("/:id", adminUserController.getUserById);

/** POST /api/v1/admin/users — Admin. Body: user fields (+ role). Returns 201 user. */
adminUserRoutes.post("/", adminUserController.createUser);

/** PUT /api/v1/admin/users/:id — Admin. Partial user body. Returns updated user. */
adminUserRoutes.put("/:id", adminUserController.updateUser);

/** PATCH /api/v1/admin/users/:id — Admin. Same as PUT (partial update). */
adminUserRoutes.patch("/:id", adminUserController.updateUser);

/** DELETE /api/v1/admin/users/:id — Admin. Deletes user or 404. */
adminUserRoutes.delete("/:id", adminUserController.deleteUser);

export default adminUserRoutes;
