#
#  Created by Boyd Multerer on 2018-09-18.
#  Copyright © 2018 Kry10 Industries. All rights reserved.
#

defmodule Scenic.Component.Input.RadioButtonTest do
  use ExUnit.Case, async: true
  doctest Scenic

  # alias Scenic.Component
  alias Scenic.Graph
  alias Scenic.Primitive
  alias Scenic.ViewPort
  alias Scenic.Component.Input.RadioButton

  @state %{
    graph: Graph.build(),
    theme: Primitive.Style.Theme.preset(:primary),
    pressed: false,
    contained: false,
    checked: false,
    id: :test_id
  }

  # ============================================================================
  # info

  test "info works" do
    assert is_bitstring(RadioButton.info(:bad_data))
    assert RadioButton.info(:bad_data) =~ ":bad_data"
  end

  # ============================================================================
  # verify

  test "verify passes valid data" do
    assert RadioButton.verify({"Title", :abc}) == {:ok, {"Title", :abc}}
    assert RadioButton.verify({"Title", :abc, true}) == {:ok, {"Title", :abc, true}}
    assert RadioButton.verify({"Title", :abc, false}) == {:ok, {"Title", :abc, false}}
  end

  test "verify fails invalid data" do
    assert RadioButton.verify(:banana) == :invalid_data
    assert RadioButton.verify({"Title", :abc, :banana}) == :invalid_data
  end

  # ============================================================================
  # init

  test "init works with simple data" do
    {:ok, state} = RadioButton.init({"Title", :test_id}, styles: %{})
    %Graph{} = state.graph
    assert is_map(state.theme)
    assert state.contained == false
    assert state.pressed == false
    assert state.checked == false
    assert state.id == :test_id

    {:ok, state} = RadioButton.init({"Title", :test_id, false}, styles: %{}, id: :test_id)
    assert state.checked == false

    {:ok, state} = RadioButton.init({"Title", :test_id, true}, styles: %{}, id: :test_id)
    assert state.checked == true
  end

  # ============================================================================
  # handle_input

  test "handle_input {:cursor_enter, _uid} sets contained" do
    {:noreply, state} =
      RadioButton.handle_input({:cursor_enter, 1}, %{}, %{@state | pressed: true})

    assert state.contained
    # confirm the graph was pushed
    assert_receive({:"$gen_cast", {:push_graph, _, _, _}})
  end

  test "handle_input {:cursor_exit, _uid} clears contained" do
    {:noreply, state} =
      RadioButton.handle_input({:cursor_exit, 1}, %{}, %{@state | pressed: true})

    refute state.contained
    # confirm the graph was pushed
    assert_receive({:"$gen_cast", {:push_graph, _, _, _}})
  end

  test "handle_input {:cursor_button, :press" do
    context = %ViewPort.Context{viewport: self()}

    {:noreply, state} =
      RadioButton.handle_input({:cursor_button, {:left, :press, nil, nil}}, context, %{
        @state
        | pressed: false,
          contained: true
      })

    assert state.pressed

    # confirm the input was captured
    assert_receive({:"$gen_cast", {:capture_input, ^context, [:cursor_button, :cursor_pos]}})
    # confirm the graph was pushed
    assert_receive({:"$gen_cast", {:push_graph, _, _, _}})
  end

  test "handle_input {:cursor_button, :release" do
    context = %ViewPort.Context{viewport: self()}

    {:noreply, state} =
      RadioButton.handle_input({:cursor_button, {:left, :release, nil, nil}}, context, %{
        @state
        | pressed: true,
          contained: true
      })

    refute state.pressed

    # confirm the input was released
    assert_receive({:"$gen_cast", {:release_input, [:cursor_button, :cursor_pos]}})

    # confirm the graph was pushed
    assert_receive({:"$gen_cast", {:push_graph, _, _, _}})
  end

  test "handle_input {:cursor_button, :release sends a message if contained" do
    self = self()
    Process.put(:parent_pid, self)
    context = %ViewPort.Context{viewport: self()}

    {:noreply, _} =
      RadioButton.handle_input({:cursor_button, {:left, :release, nil, nil}}, context, %{
        @state
        | pressed: true,
          contained: true
      })

    # confirm the graph was pushed
    assert_receive({:"$gen_cast", {:event, {:click, :test_id}, ^self}})
  end

  test "handle_input does nothing on unknown input" do
    context = %ViewPort.Context{viewport: self()}
    {:noreply, state} = RadioButton.handle_input(:unknown, context, @state)
    assert state == @state
  end
end
