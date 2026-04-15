# Messenger Pub/Sub 🚀

نظام **Message Broker** مصغر مبني بلغة **Elixir**، بيعتمد على نمط الـ **Pub/Sub** لإدارة الرسايل بين الـ Processes بشكل Async ومنظم.

---

## نظرة عامة (Technical Overview)

المشروع بيستخدم **GenServer** كـ Orchestrator لإدارة الـ Subscriptions وتوزيع الرسايل. الهدف هو توفير وسيلة تبادل بيانات بين أجزاء السيستم المختلفة بناءً على الـ Topics، مع ضمان سلامة البيانات وحالة الـ Processes المشتركة.

---

## المميزات التقنية (Core Features)

- **Process Monitoring:** بنستخدم `Process.monitor/1` عشان نراقب الـ Subscribers؛ لو أي Process حصل لها Crash أو اتفصلت، السيستم بيعمل Cleanup تلقائي للـ State عشان يتجنب الـ Memory Leaks.

- **Message Archiving:** الرسايل بتتحفظ في طابور باستخدام الـ `:queue` Erlang module، وده بيضمن كفاءة الإضافة والحذف $O(1)$ للأرشفة.

- **Decoupling:** السيستم بيفصل تماماً بين الـ Publisher والـ Subscriber، وده بيسهل عملية الـ Scaling وتطوير الـ Microservices داخل الـ Node.

---

## التشغيل والتجربة (Quick Start)

داخل الـ `iex` shell، اتبع الخطوات دي:

### 1. Initialization

```elixir
Messenger.start_link()
```

### 2. Subscribing

```elixir
Messenger.subscribe("tech_topic")
```

### 3. Publishing

```elixir
Messenger.publish("tech_topic", "New update available!")
```

### 4. Message Retrieval

للتأكد من وصول الرسايل للـ Mailbox بتاعك:

```elixir
flush()
```

---

## الـ API Reference 🕹️

| Function | Description |
|---|---|
| `subscribe(topic)` | تسجيل الـ Caller PID كـ Subscriber في Topic معين. |
| `unsubscribe(topic)` | حذف الـ Caller PID من قائمة المشتركين لموضوع معين. |
| `publish(topic, msg)` | عمل Broadcast للرسالة لكل الـ PIDs المسجلين في الـ Topic. |
| `get_subscribers(topic)` | إرجاع عدد الـ Subscribers الحاليين لموضوع معين. |

---

## ملاحظة  📝

> المشروع حالياً في مرحلة الـ **Proof of Concept**. لتحسين الـ Throughput في حالات الضغط العالي، الخطة الجاية هي استبدال الـ **Map** بـ **ETS Tables** لتقليل الـ Lock على الـ GenServer State وتوفير Concurrency أعلى.
