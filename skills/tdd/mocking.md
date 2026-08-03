# 何时使用模拟（Mock）

只在**系统边界（system boundaries）**使用模拟：

- 外部 API（支付、邮件等）
- 数据库（有时需要——优先使用测试数据库）
- 时间／随机性
- 文件系统（有时需要）

不要模拟：

- 你自己的类／模块
- 内部协作者
- 任何由你控制的对象

## 为可模拟性设计（Designing for Mockability）

在系统边界处，应设计易于模拟的接口：

**1. 使用依赖注入（dependency injection）**

从外部传入依赖，而不是在内部创建：

```typescript
// Easy to mock
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to mock
function processPayment(order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

**2. 优先使用 SDK 风格接口，而不是通用请求器**

为每种外部操作创建专用函数，避免用一个包含条件逻辑的通用函数：

```typescript
// GOOD: Each function is independently mockable
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch('/orders', { method: 'POST', body: data }),
};

// BAD: Mocking requires conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

SDK 方式意味着：
- 每个 mock 都只返回一种特定结构
- 测试设置中没有条件逻辑
- 更容易看出测试覆盖了哪些端点
- 每个端点都有类型安全保障
