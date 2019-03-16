defmodule DemoWeb.TablesLive do
  use Phoenix.LiveView

  @initial_table [["English", "Français"], ["Hello", "Bonjour"]]

  def render(assigns) do
    ~L"""
      <form phx-change="update_cell">
        <table>
          <%= for {row, row_index} <- Enum.with_index(@table) do %>
            <tr value="<%= row_index %>">
              <%= for {cell, cell_index} <- Enum.with_index(row) do %>
                <td phx-click="select_cell" phx-value="<%= "#{row_index},#{cell_index}" %>">
                  <%= if @selected_cell == "#{row_index},#{cell_index}" do %>
                      <input type="text" name="<%= "#{row_index},#{cell_index}" %>" value="<%= cell %>" />
                  <% else %>
                    <%= if cell do %><%= cell %><% else %><i>Empty</i><% end %>
                  <% end %>
                </td>
              <% end %>
            </tr>
          <% end %>
        </table>
      </form>

      <button phx-click="add_row">Add row</button>
      <button phx-click="add_column">Add column</button>

      <pre>
        <%= inspect(@table) %>
      </pre>
    """
  end

  def mount(_session, socket) do
    {:ok, assign(socket, table: @initial_table, selected_cell: nil)}
  end

  def handle_event("add_row", _, socket) do
    {:noreply, update(socket, :table, &add_row(&1))}
  end

  def handle_event("add_column", _, socket) do
    {:noreply, update(socket, :table, &add_column(&1))}
  end

  def handle_event("select_cell", cell_coord, socket) do
    {:noreply, update(socket, :selected_cell, fn _ -> cell_coord end)}
  end

  def handle_event("update_cell", params, socket) do
    {:noreply, update(socket, :table, &update_table(&1, params))}
  end

  def add_row(table) do
    columns_count = Enum.count(Enum.at(table, 0)) || 0
    new_row = for(_x <- 0..(columns_count - 1), do: nil)

    table ++ [new_row]
  end

  def add_column(table) do
    Enum.map(table, fn row -> row ++ [nil] end)
  end

  def update_table(table, new_values) do
    Enum.reduce(new_values, table, fn {coord, new_value}, acc_table ->
      update_cell(acc_table, coord, new_value)
    end)
  end

  def update_cell(table, coord, new_value) do
    [row_index, column_index] =
      coord
      |> String.split(",")
      |> Enum.map(&String.to_integer(&1))

    List.update_at(table, row_index, fn row ->
      List.update_at(row, column_index, fn _ -> new_value end)
    end)
  end
end
