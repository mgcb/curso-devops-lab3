FROM node:24 as build

#solo define en la carpeta en la que estare dentro del contenedor
WORKDIR /app

#copiar todas los archivos
COPY ./ ./

#instalar dependencias (dev y prod)
RUN npm install

#construir el proyecto (compilar el codigo)
RUN npm run build

FROM node:24-alpine

WORKDIR /usr/app

COPY --from=build /app/dist /usr/app/dist
COPY --from=build /app/package*.json /usr/app/

RUN npm install --only=production 

#Indica que puerto mostrar
EXPOSE 3000

CMD ["node", "dist/main.js"]