import { Router } from "express";
import { RegistrationController } from "../controllers/registration.controller";
import { RegistrationMongoRepository } from "../repositories/registration.repository";
import { EventMongoRepository } from "../repositories/event.repository";
import { RegistrationService } from "../services/registration.service";
import { authorizedMiddleware } from "../middlewares/authorized.middleware";

const registrationRepository = new RegistrationMongoRepository();
const eventRepository = new EventMongoRepository();
const registrationService = new RegistrationService(registrationRepository, eventRepository);
const registrationController = new RegistrationController(registrationService);

const router = Router();

/** GET /api/v1/registrations/my — Bearer. Returns caller's registrations. */
router.get("/my", authorizedMiddleware, registrationController.getMyRegistrations);

/** GET /api/v1/registrations/event/:eventId — Bearer. Returns registrations for an event (403/404 possible). */
router.get("/event/:eventId", authorizedMiddleware, registrationController.getEventRegistrations);

/** POST /api/v1/registrations — Bearer. Body: eventId. Returns 201 registration. */
router.post("/", authorizedMiddleware, registrationController.register);

/** DELETE /api/v1/registrations/:id — Bearer. Cancels own registration or 403/404. */
router.delete("/:id", authorizedMiddleware, registrationController.cancel);

export default router;
