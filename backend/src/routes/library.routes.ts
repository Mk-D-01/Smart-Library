import { Router } from 'express';
import { BookController, MemberController } from '../controllers/library.controller';

const router = Router();

// Book Routes
router.get('/books', BookController.getAllBooks);
router.get('/books/:id', BookController.getBookById);
router.post('/books', BookController.createBook);
router.put('/books/:id', BookController.updateBook);
router.delete('/books/:id', BookController.deleteBook);

// Member Routes
router.get('/members', MemberController.getAllMembers);
router.get('/members/:id', MemberController.getMemberById);
router.post('/members', MemberController.createMember);
router.put('/members/:id', MemberController.updateMember);
router.delete('/members/:id', MemberController.deleteMember);

export default router;
