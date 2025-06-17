alias FreeForum.Accounts.User
alias FreeForum.UserContent.Topic
alias FreeForum.UserContent.Comment

user1 = FreeForum.Repo.insert! %User{
  email: "showcaseuser@example.com",
  username: "ForumDweller",
  hashed_password: Pbkdf2.hash_pwd_salt("1234"),
  vip: false
}

user2 = FreeForum.Repo.insert! %User{
  email: "victim@example.com",
  username: "VictimUser",
  hashed_password: Pbkdf2.hash_pwd_salt("1234"),
  vip: false
}

user3 = FreeForum.Repo.insert! %User{
  email: "hacker@example.com",
  username: "Hack3rM4n",
  hashed_password: Pbkdf2.hash_pwd_salt("1234"),
  vip: false
}

user4 = FreeForum.Repo.insert! %User{
  email: "vip@example.com",
  username: "Vasily Ivanovich",
  hashed_password: Pbkdf2.hash_pwd_salt("1234"),
  vip: true
}

topic1 = FreeForum.Repo.insert! %Topic{
  author_id: user4.id,
  title: "СМИ: Piranha Bytes до закрытия работала над Elex 3",
  content: """
    Игру уже можно было пройти от начала до конца, но работы было ещё много.
    <div class="py-2 rounded-xs">
      <img src="https://leonardo.osnova.io/a27fad19-79b9-5952-89b8-a035df2506be/-/scale_crop/592x/-/format/webp/" />
    </div>
    <ul>
      <li>
        Elex 3 стала последней игрой, над которой трудились сотрудники студии Piranha Bytes,
        закрывшейся летом 2024 года. Об этом сообщили в немецком издании GameStar со ссылкой на бывших разработчиков команды.
      </li>
      <li>
        К моменту закрытия в Piranha Bytes достигли значительного прогресса в разработке Elex 3,
        известной под кодовым названием Singularity. Ролевой экшен уже можно было пройти от начала до конца,
        но работы ещё предстояло много. В игре оставалось множество незаконченных графических объектов,
        нужно было исправлять баги, а локализация отсутствовала.
      </li>
      <li>
        Масштаб игры Elex 3 значительно уменьшили из-за сокращения расходов в связи с финансовыми трудностями компании Embracer.
        Чтобы не отказываться от проекта, разработчики существенно сократили многие зоны открытого мира.
      </li>
    </ul>

    Польские <a href="https://dtf.ru/gameindustry/2798386-polskie-smi-soobshili-o-zakrytii-piranha-bytes-oficialnoi-informacii-net">СМИ</a>
    сообщили о закрытии Piranha Bytes в июле 2024 года. Спустя несколько дней после этого бывший творческий руководитель студии Бьорн Панкрац
    и его жена Дженнифер основали собственную студию Pithead.
    В одном из видео на своём YouTube-канале они сообщили, что от Piranha Bytes остался только бренд.
  """,
  latest_activity: NaiveDateTime.local_now(),
  views: 154,
  replies: 4
}

comment_1_1 = FreeForum.Repo.insert! %Comment{
  author_id: user2.id,
  topic_id: topic1.id,
  content: "Очень жаль, третья Готика была лучшей частью, Елех 3 был бы тоже",
}

comment_1_2 = FreeForum.Repo.insert! %Comment{
  author_id: user3.id,
  topic_id: topic1.id,
  replies_to: comment_1_1.id,
  content: "Ризен лучше любой из Готик.",
}

comment_1_3 = FreeForum.Repo.insert! %Comment{
  author_id: user2.id,
  topic_id: topic1.id,
  replies_to: comment_1_2.id,
  content: "Надеюсь ты про четвёртую часть?",
}

comment_1_4 = FreeForum.Repo.insert! %Comment{
  author_id: user3.id,
  topic_id: topic1.id,
  replies_to: comment_1_3.id,
  content: """
    Ризен и есть четвёртая часть Готики. Она изначально разрабатывалась как ДЛС к третьей части,
    но т. к. пираний лишили прав на серию, пришлось все имена и названия в игре менять под новый бренд.
  """
}

FreeForum.Repo.insert! %Topic{
  author_id: user1.id,
  title: "Что за штука?",
  content: """
    Нашел на улице железку какую-то, в виде буквы "Е",
    не знает кто-нибудь что это??
    <img src="https://static1-repo.aif.ru/1/01/1114977/808f5d2e9112794bef51a11b0984fb0e.jpg" />
  """,
  latest_activity: NaiveDateTime.from_iso8601!("2025-06-13T12:03:17"),
  views: 11,
  replies: 0
}
