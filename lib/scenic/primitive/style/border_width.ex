#
#  Created by Boyd Multerer on 5/12/17.
#  Copyright © 2017 Kry10 Industries. All rights reserved.
#

defmodule Scenic.Primitive.Style.BorderWidth do
  use Scenic.Primitive.Style
#  alias Scenic.Primitive.Style

#  @dflag            Style.dflag()
#  @type_code        0x0020



  #============================================================================
  # data verification and serialization

  #--------------------------------------------------------
  def info(), do: "Style :border_width must be an integer between 0 and 255"

  #--------------------------------------------------------
  def verify( width ) when is_integer(width) and
    (width >= 0) and (width <= 255), do: true
  def verify( _ ), do: false

  #--------------------------------------------------------
  def serialize( data, order \\ :native )
  def serialize( width, _ ) do
    << width :: size(8) >>
  end

  #--------------------------------------------------------
  def deserialize( binary_data, order \\ :native )
  def deserialize( <<
      width   :: size(8),
      bin     :: binary
    >>, _ ) do
    {:ok, width, bin}
  end
  def deserialize( binary_data, order ), do: {:err_invalid, binary_data, order }



end