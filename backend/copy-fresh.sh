#!/bin/bash
echo "Copying fresh source files to container..."
docker cp src/config/supabase.ts smart-library-backend-1:/app/src/config/
docker cp src/models/library.model.ts smart-library-backend-1:/app/src/models/
docker cp src/routes/library.routes.ts smart-library-backend-1:/app/src/routes/
docker cp src/server.ts smart-library-backend-1:/app/src/server.ts
echo "Files copied successfully!"
