---
title: Yet untitled, about TCP and TLS and Haskell
updatedOn: Jun 06, 2013
---
Isn't TCP networking in Haskell super easy? Why, of course it is! It was just a
rhetorical question, so funny. See for yourself:

    main = withSocketsDo $ do
        connect "www.haskell.com" "80" $ \(socket,_) -> do
            send socket "GET / HTTP/1.0\r\n\r\n"
            recv socket 1000 >>= print

Look at that! In 4 lines of Haskell code we've established a TCP connection to
the [www.haskell.com][haskell] web site and printed up to 1000 characters of
HTTP content to the console.

Well, actually… I'm sorry, I lied. Don't you ever lie. The truth is that once
you add the import statements and enable some compiler magic the code gets a bit
longer:

    {-# LANGUAGE OverloadedStrings #-}
    import Network.Simple.TCP

    main = withSocketsDo $ do
        connect "www.haskell.com" "80" $ \(socket,_) -> do
            send socket "GET / HTTP/1.0\r\n\r\n"
            recv socket 1000 >>= print

That is the whole thing now, I promise. 2 lines longer. Isn't that tight? Yes,
yes it is. But what is *that*, anyway? Let me explain.

## TCP one-oh-one

It is crucial that you understand the basics of TCP network connections and how
your operating systems deals with them before we go any further in our Haskell
journey, so let's start with that.

A [TCP connection][tcp] is a reliable, ordered and error-free communication
channel between two computer programs, and operating systems expose each of
those channel endpoints as [network sockets][network-socket].

A TCP connection is said to be **reliable** because each piece of data sent to
the other connection end has to be acknowledged once received, otherwise the TCP
protocol, all by itself, will re-transmit the same data until acknowledged. That
stubborn old protocol! Well… not that stubborn actually, since it also
understands that many other computers might also be trying to use the internet
at the same time, and in the same way traffic in the streets gets stuck if too
many vehicles try to take the same road at once, including you, internet also
gets stuck if vehicle drivers are not gentle. I mean, the computers. I guess
that's why they call these things
[network communication protocols][network-comm-protocol]; you have to play by
the rules and kindly share the internet with your peers, otherwise they get
angry, honk at you and start telling you appart from themselves—the nice car
drivers who respect each other and understand the complexity of the
streets. Also, you need to be gentle, because you see, the computer you are
trying to reach might not be as fast as yours, so be kind to her, give it
time. Besides, you have to learn how much data you are supposed to send at
once. Say you want to send your fiend overseas a song, a really long song. You
can't expect your friend's computer, kilometers away, to receive the whole thing
at once in less than one second. Light-speed travel, Warp drive, teleportation…
we aren't there yet amigo. So instead, you split the millon bytes that make up
your song in small enough pieces, putting them in individual **packets** and
sending those to you friend one after another as if in a **stream**. At an
acceptable rate of course, so that no one honks at you on the way, not even
her. Beep, beep! Anyway, luckily you can *mostly* ignore all these politeness
issues as a modern software developer, since some other smart guys have already
implemented the TCP protocol for you in modern operating systems. Do properly
learn about all these things some day, though. Really. It's a nice gentleman
that TCP protocol, a fair guy.

Overseas, your friend may start listening to the first seconds of your song
while still receiving the rest of it. The reason she's able to do this is
because TCP guarantees **ordered** delivery, meaning that when putting the
received packets back together to reproduce the sent stream, it is always done
in the same order that the packets were sent. It doesn't matter if your friend's
computer received the second second of the song first and then the first
second; the operating system *will* give you the first second first, and then
the second second second. In any case, your friend maybe didn't enjoy the boring
song you sent her and after listening to the first minute she stopped
reproducing it. No problemo, the TCP connection gets closed and your computer
stops sending the stream of musical bytes.

I just sneaked in a little secret a while back: the internet is made of
TCP. Well… not just TCP, there are also a handful other communication protocols,
and wires and people and science. But TCP is some really serious stuff when it
comes to internet. These words of mine you are reading? They were sent to you
through a TCP connection, since that's what the HTTP protocol is usually made
of. Oh… you don't know what HTTP is? Don't worry right now, I'll tell you in
detail later. Also, it's not that TCP is only useful for making the internet;
TCP connections happen all day long between computers that are not connected to
the internet also. Maybe you are too young and can't really fathom the idea, but
there was a time when computers were not always connected to the internet, and
not by accident, yet they shared software, poems, songs and words with each
other using pretty much the same technology internet use today, including
TCP. You know, you could have a cable plugged to your computer at one end and to
your neighbor's at the other, and somehow use that cable. Of course you could do
this today too, but sadly less and less people seem to know how as time goes
by. We have the cloud, right? Pfft. What do *we* have?

We have **error-free** communication?

 [haskell]: http://www.haskell.com
 [tcp]: http://en.wikipedia.org/wiki/Transmission_Control_Protocol
 [network-socket]: https://en.wikipedia.org/wiki/Network_socket
 [network-comm-protocol]: http://en.wikipedia.org/wiki/Communications_protocol
