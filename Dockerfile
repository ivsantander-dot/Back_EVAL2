# ── ETAPA 1: Builder ───────────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar solo archivos de dependencias primero (optimiza caché)
COPY package*.json ./

# Instalar TODAS las dependencias (incluyendo devDependencies)
RUN npm ci

# Copiar el resto del código fuente
COPY . .

# Si tu proyecto necesita paso de build (TypeScript, etc.)
# RUN npm run build

# ── ETAPA 2: Runner (imagen final liviana) ─────────────────────
FROM node:18-alpine AS runner

# Crear usuario no root por seguridad (mínimo privilegio)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copiar solo lo necesario desde el builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
# Si usas build: COPY --from=builder /app/dist ./dist

# Cambiar propietario de archivos al usuario no root
RUN chown -R appuser:appgroup /app

# Cambiar al usuario no root
USER appuser

# Puerto que expone el servicio (ajusta al tuyo)
EXPOSE 3000
