(

var port, users;

users = IdentityDictionary();

15.do({|group|

	port = group + NetAddr.langPort;
	thisProcess.openUDPPort(port);

	OSCdef(\id++group, {|msg, time, sender, port|
		var colleague;
		colleague = GroupColleague(msg[1], sender, port);
		users.put(colleague.asSymbol, colleague);

		users.do({|user|
			user.netAddr.sendMsg(msg)
		});

	}, "/%/id".format(group))
})
)