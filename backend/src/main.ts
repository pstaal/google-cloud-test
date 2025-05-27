import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ConfigService } from '@nestjs/config';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = await app.get<ConfigService>(ConfigService);
  app.enableCors({
    allowedHeaders: [
      'Accept',
      'Accept-Version',
      'Content-Type',
      'Api-Version',
      'Origin',
      'X-Requested-With',
      'Authorization',
    ],
    methods: ['POST', 'PUT', 'DELETE', 'GET', 'PATCH'],
    origin: configService.get('CORS'),
    credentials: true,
  });

  const PORT = configService.get('APP_PORT');
  const HOST = configService.get('APP_HOST');
  const URL = `${HOST}:${PORT}`;
  await app.listen(PORT);
  console.log(`Backend up and running at ${URL}`);
}
bootstrap();
