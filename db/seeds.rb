# Seeds are optional: this application boots, migrates, and serves every page
# with a completely empty database, and nothing here is required in
# production.
#
# The first operator account is promoted from the console on purpose; there is
# deliberately no seeded administrator, password, or API key anywhere in this
# repository.

# RogueDelve: a few sample leaderboard entries so the board isn't empty on a
# fresh database. Safe to run repeatedly.
sample_entries = [
  { player_name: "Kestrel", kills: 34, score: 780, depth: 5, result: "won" },
  { player_name: "Tarn", kills: 21, score: 540, depth: 4, result: "dead" },
  { player_name: "Moss", kills: 15, score: 410, depth: 3, result: "dead" },
  { player_name: "Pike", kills: 9, score: 230, depth: 2, result: "dead" }
]

sample_entries.each do |attrs|
  next if ScoreEntry.exists?(player_name: attrs[:player_name], score: attrs[:score])

  ScoreEntry.create!(
    player_name: attrs[:player_name],
    kills: attrs[:kills],
    score: attrs[:score],
    depth: attrs[:depth],
    result: attrs[:result]
  )
end

puts "Seeded #{ScoreEntry.count} score entries."
