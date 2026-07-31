import { Router } from "express";
import { EventController } from "../controllers/event.controller";
import { EventMongoRepository } from "../repositories/event.repository";
import { EventService } from "../services/event.service";
import { authorizedMiddleware, adminMiddleware } from "../middlewares/authorized.middleware";

const eventRepository = new EventMongoRepository();
const eventService = new EventService(eventRepository);
const eventController = new EventController(eventService);

const router = Router();

/** GET /api/v1/events — Public. Returns all events. */
router.get("/", eventController.getAllEvents);

/** GET /api/v1/events/:id — Public. Returns event or 404. */
router.get("/:id", eventController.getEventById);

/** POST /api/v1/events — Admin. Body: title, date, location, etc. Returns 201 event. */
router.post("/", authorizedMiddleware, adminMiddleware, eventController.createEvent);

/** PUT /api/v1/events/:id — Admin. Partial event body. Returns updated event or 404. */
router.put("/:id", authorizedMiddleware, adminMiddleware, eventController.updateEvent);

/** DELETE /api/v1/events/:id — Admin. Deletes event or 404. */
router.delete("/:id", authorizedMiddleware, adminMiddleware, eventController.deleteEvent);

export default router;
