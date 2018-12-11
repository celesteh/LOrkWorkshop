(

var port, users;

users = IdentityDictionary();
NetAddr.broadcastFlag = true;

15.do({|group|

	port = group + NetAddr.langPort -3;
	thisProcess.openUDPPort(port);

	OSCdef(\id++group, {|msg, time, sender, port|
		var colleague, ip;

		msg.postln;
		(msg.size > 3).if({
			port = msg[3];
		});
		(msg.size > 2).if({
			ip = msg[2];
			sender = NetAddr(ip, port);
			msg = msg ++ [ip, port];
		});


		colleague = GroupColleague(msg[1], sender, port);
		users.put(colleague.asSymbol, colleague);

		users.do({|user|
			user.netAddr.sendMsg(msg)
		});

	}, "/%/id".format(group));

	"/%/id, %".format(group, port).postln;
})
)