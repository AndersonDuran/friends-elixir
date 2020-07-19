import Config

config :friends_app, csv_file: "#{File.cwd!()}/friends.csv"

import_config "#{File.cwd!()}/config.exs"
