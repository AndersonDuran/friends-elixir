defmodule FriendsApp.CLI.Menu.Itens do
  alias FriendsApp.CLI.Menu

  def all, do: [
    %Menu{ label: "Cadastrar Amigo", id: :create},
    %Menu{ label: "Listar Amigos", id: :read},
    %Menu{ label: "Atualizar Amigo", id: :update},
    %Menu{ label: "Deletar Amigo", id: :delete},
  ]
end
