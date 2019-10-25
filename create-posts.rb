require 'json'
require 'pp'
require 'time'
require 'mail'
require 'cgi'

def main
    previous_topic_id = get_json('topics.json')["ygData"]["lastTopic"]

    while previous_topic_id != 0 do
        filename = "topic-#{previous_topic_id}.json"
        json = get_json("topic-#{previous_topic_id}.json")
        create_post(json)

        previous_topic_id = json["ygData"]["prevTopicId"]
    end
end

BAD_TOPICS = [21757]

def create_post(json)
    messages = json["ygData"]["messages"].reverse.map { |m| get_post_data(m) }
    initial_message = messages.first

    return if BAD_TOPICS.include? initial_message["id"]

    last_message = messages.last

    responses = messages - [initial_message]

    body = messages.map do |message|
        <<-EOM
<article>
<h4>#{message["author"]}</h4>
<time>#{format_time(message["time"])}</time>

#{message["body"]}
</article>
        EOM
    end.join('<hr style="margin: 3em 0"/>')

    post_filename = "#{initial_message["time"].strftime("%F")}-#{initial_message["id"]}.html"
    post_content = <<-EOP
---
layout: post
title: >-
  #{initial_message["title"]}
date: #{last_message["time"].to_s}
author: >-
  #{initial_message["author"]}
slug: "#{initial_message["id"]}"
excerpt_separator: <!--there-is-no-excerpt-separator-expected-ever-->
description: ""
---
{% raw %}
#{body}
{% endraw %}
    EOP

    responders = responses.map do |r|
        r["author"]
    end.uniq - [initial_message["author"]]

    puts "Creating #{post_filename} #{post_content.size} [#{initial_message["title"]}] by #{initial_message["author"]}, #{responders.join(", ")}"
    IO.write("_posts/#{post_filename}", post_content)
end

def format_time(time)
    (time - 7 * 3600).strftime("%e %b %Y, at %l:%M%P")
end

def get_post_data(message)
    {
        "id" => message["topicId"],
        "title" => CGI.unescapeHTML(message["subject"] || ""),
        "time" => Time.at(message["postDate"].to_i).utc,
        "author" => get_author(message),
        "body" => message["messageBody"]
    }
end

def get_author(message)
    if message["authorName"].size > 0 then
        message["authorName"]
    elsif message["from"].size > 0 then
        Mail::Encodings.value_decode(message["from"])
    elsif message["profile"].size > 0 then
        message["profile"]
    end
end

def get_json(filename)
    path = "cache/#{filename}"
    JSON.parse(IO.read(path))
end

main
