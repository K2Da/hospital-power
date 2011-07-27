def hospital(s, d)
  s.gsub(/player:(\w+)/) { |m|
    p = m[7..-1]
    '<a href="' + d.to_day_link + 'player/' + p + '/">' + p + '</a>'
  }.gsub(/-\d\d:\d\d:\d\d-\w+-/) { |m|
    t = m[1..8]
    l = m[10..-2]
    '<a href="' + d.to_day_link + 'from/' + t + '/">' + l + '</a>'
  }.gsub(/id:(\S+)/) { |m|
    i = m[3..-1]
    '<a href="' + d.to_day_link + 'id/' + i.gsub('+', '%2b') + '/">' + i + '</a>'
  }
end

ARTICLE = {
=begin
  Time.new(2011, 7, ) =>
  [
    { :title => '',
      :text  => hospital(<<"EOT", Time.new(2011, 7, ))
%p
EOT
    },
    { :title => '',
      :text  => hospital(<<"EOT", Time.new(2011, 7, ))
%p
EOT
    }
  ],
=end
  Time.new(2011, 7, 27) =>
  [
    { :title => 'Summer vandalist comes',
      :text  => hospital(<<"EOT", Time.new(2011, 7, 27))
%p Summer vandalist id:qwg8oC/WO came Umehara general thread this morning.
EOT
    }
  ],
  Time.new(2011, 7, 26) =>
  [
    { :title => 'Sako will not join Evo',
      :text  => hospital(<<"EOT", Time.new(2011, 7, 26))
%p Akiki revealed that player:Sako will not attend Evo.
EOT
    },
    { :title => 'Pro players mental health',
      :text  => hospital(<<"EOT", Time.new(2011, 7, 26))
%p Ume-thread folks were worried about pro players' mental health at -01:34:36-midnight-.
EOT
    }
  ],
  Time.new(2011, 7, 25) =>
  [
    { :title => 'RF got his own Shift_JIS art',
      :text  => hospital(<<"EOT", Time.new(2011, 7, 25))
%p A craftworker in AA board made a Shift_JIS art for player:RF. Check <a href="http://hospitalpwr.cloudfoundry.com/thread/1311601236/res/409/">it</a>.
EOT
    }
  ],
  Time.new(2011, 7, 24) =>
  [
    { :title => 'Poongko v.s. Japanese players in Tokyo',
      :text  => hospital(<<"EOT", Time.new(2011, 7, 24))
%p Korean player player:Poongko came to Ikebukuro Safari and Shinjuku TAITO STATION. He played many Japanese players, including player:Inoue and player:Hood.
EOT
    },
    { :title => 'BonChan and Momochi won SBO Preliminary Area final in Nagoya',
      :text  => hospital(<<"EOT", Time.new(2011, 7, 24))
%p player:BonChan and player:Momochi won SBO Preliminary Area final in Nagoya. The recorded stream is in <a href ="http://www.ustream.tv/recorded/16209040">nsb on USTREAM</a>.
EOT
    }
  ],
  Time.new(2011, 7, 23) =>
  [
    { :title => 'nsb x nsb nico stream battle PS3',
      :text  => hospital(<<"EOT", Time.new(2011, 7, 23))
%p player:Momochi won the nsb x nsb. He will join GODSGARDEN #4.
EOT
    },
    { :title => 'Legendary Q player is read in SSFIV AE',
      :text  => hospital(<<"EOT", Time.new(2011, 7, 23))
%p Totalheads announced that Legendary Q player was ready in STREET FIGHTER IV AE. Anyway, player:Kuroda attended the SBO quolification today.
EOT
    }
  ]
}
