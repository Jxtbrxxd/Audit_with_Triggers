
**Audit with Triggers** is a PostgreSQL project that demonstrates the use of triggers and audit logs to track changes made to an `employees` table. The project includes:
- Creating an `employees` table and an `employee_audit` table for logging operations.
- Using a sequence to generate unique audit IDs.
- Implementing triggers to capture `INSERT`, `UPDATE`, and `DELETE` actions.
- Recording changes such as salary updates, department changes, and user operations for transparent auditing.
