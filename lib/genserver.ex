defmodule Messenger do
  use GenServer

  defstruct subscribers: %{},
            messages: :queue.new(),
            rate_limits: %{}

  def start_link(_opts \\ []), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

  def subscribe(topic, pid \\ self()) do
    GenServer.call(__MODULE__, {:subscribe, topic, pid})
  end

  def unsubscribe(topic, pid \\ self()) do
    GenServer.call(__MODULE__, {:unsubscribe, topic, pid})
  end

  def publish(topic, message) do
    GenServer.cast(__MODULE__, {:publish, topic, message})
  end

  def get_subscribers(topic) do
    GenServer.call(__MODULE__, {:get_subscribers, topic})
  end

  @impl true
  def init(_) do
    {:ok, %__MODULE__{subscribers: %{}, messages: :queue.new(), rate_limits: %{}}}
  end

  @impl true
  def handle_call({:subscribe, topic, pid}, _from, state) do
    Process.monitor(pid)
    new_subscribers = Map.update(state.subscribers, topic, [pid], &[pid | &1])
    {:reply, :ok, %{state | subscribers: new_subscribers}}
  end

  @impl true
  def handle_call({:unsubscribe, topic, pid}, _from, state) do
    new_subscribers =
      Map.update(state.subscribers, topic, [], fn pids -> List.delete(pids, pid) end)

    {:reply, :ok, %{state | subscribers: new_subscribers}}
  end

  @impl true
  def handle_call({:get_subscribers, topic}, _from, state) do
    subscribers = Map.get(state.subscribers, topic, [])
    {:reply, length(subscribers), state}
  end

  @impl true
  def handle_cast({:publish, topic, message}, state) do
    subscribers = Map.get(state.subscribers, topic, [])

    Enum.each(subscribers, fn pid ->
      send(pid, {:notification, topic, message, System.monotonic_time()})
    end)

    new_messages = :queue.in({topic, message, System.monotonic_time()}, state.messages)
    {:noreply, %{state | messages: new_messages}}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    new_subscribers =
      Map.new(state.subscribers, fn {topic, pids} ->
        {topic, List.delete(pids, pid)}
      end)

    {:noreply, %{state | subscribers: new_subscribers}}
  end
end
