import { Body, Controller, Get, Post } from '@nestjs/common';

@Controller('orders')
export class OrdersController {

  @Get()
  async list() {
    return [];
  }

  @Post()
  async create(@Body() order) {
    return order;
  }
}
