defmodule InvoiceWeb.PageController do
  use InvoiceWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
