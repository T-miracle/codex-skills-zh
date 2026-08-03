# 好测试与坏测试（Good and Bad Tests）

## 好测试（Good Tests）

**集成式（Integration-style）**：通过真实接口测试，而不是模拟内部部件。

```typescript
// GOOD: Tests observable behavior
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});
```

特征：

- 测试用户／调用者关心的行为
- 只使用公共 API
- 能经受内部重构
- 描述“做什么（WHAT）”，而不是“怎么做（HOW）”
- 每个测试只包含一个逻辑断言

## 坏测试（Bad Tests）

**实现细节测试（Implementation-detail tests）**：与内部结构耦合。

```typescript
// BAD: Tests implementation details
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

危险信号（Red flags）：

- 模拟内部协作者
- 测试私有方法
- 对调用次数／顺序作断言
- 行为未变，仅重构就导致测试失败
- 测试名称描述 HOW 而不是 WHAT
- 绕过接口，通过外部手段验证

```typescript
// BAD: Bypasses interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: Verifies through interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

**同义反复式测试（Tautological tests）**：预期值重复实现逻辑，因此测试从构造上就会通过。

```typescript
// BAD: Expected value is recomputed the way the code computes it
test("calculateTotal sums line items", () => {
  const items = [{ price: 10 }, { price: 5 }];
  const expected = items.reduce((sum, i) => sum + i.price, 0);
  expect(calculateTotal(items)).toBe(expected);
});

// GOOD: Expected value is an independent, known literal
test("calculateTotal sums line items", () => {
  expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
});
```
