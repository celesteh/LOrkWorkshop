NetworkManager {

	var <name, <group, <netAddr, <others, <port, user_update_listeners, startup;

	* new {|me, group, ip = "255.255.255.255", port|
		^super.new.init(me, group, ip, port);
	}



	*gui { |ip = "255.255.255.255", port, action|

		^super.new.guiInit(ip, port, action)
	}

	guiInit { |ip, port, action|


		var win, layout, grp, name, button, me, group;

		startup =Semaphore(1);

		startup.wait;

		AppClock.sched(0, {
			win = Window("Start");
			layout = FlowLayout(win.view.bounds);
			win.view.decorator = layout;
			name = EZText(win, label:"Name", initVal:"YourName");
			layout.nextLine;
			grp = EZListView(win, label:"Group", items:[\1, \2, \3, \4, \5, \6, \7], layout:\horz);
			layout.nextLine;
			button = Button(win).states_([["OK", Color.black]]).action_({
				var me, gr;
				me = name.textField.value;
				me.postln;
				gr = grp.value;
				gr.postln;
				this.init(me, gr, ip, port);
				win.close;
				action.value(this);
			});
			win.front;
		});
	}


	init {|me, grp, ip, prt|

		var idtag, semaphore;

		startup.isNil.if({
			startup = Semaphore(1);
		});

		NetAddr.broadcastFlag = true;
		name = me;
		group = grp;
		prt.isNil.if ({ port = NetAddr.langPort + group}, {port = prt});
		port.postln;
		netAddr = NetAddr(ip, port);

		others = [];
		user_update_listeners = Dictionary.new;

		startup.signal;

		idtag = this.tag("/id");

		semaphore = Semaphore(1);

		this.addResp("/id", {|msg|

			var person, flag;
			person = msg[1];

			// don't add myself
			(person.asString != me.asString).if({

				{
					// don't add the same person twice
					semaphore.wait; // prevent race conditions
					flag = false;
					others.do({|colleague|
						(person.asString == colleague.asString).if ({ flag = true });
					});
					flag.not.if ({ // if this person is not in the others array
						others = others.add(person);
						user_update_listeners.do({|action|
							action.value(person);
						});
					});
					semaphore.signal;
				}.fork;
			})
		}, "/id");

		this.identify(idtag).play;
	}

	tag { |tag|
		//tag.asString.endsWith("/").not.if({
		//	tag = tag.asString ++ "/"
		//});
		//tag = tag.asString ++ group;

		tag = group.asString ++ "/" ++ tag;

		^tag.asSymbol;
	}


	identify {|idtag|
		^Task({
			inf.do({
				netAddr.sendMsg(idtag, name);
				5.wait;
			});
		})
	}


	add_user_update_listener { |owner, action|

		user_update_listeners = user_update_listeners.put(owner, action);
	}

	remove_user_update_listener { |owner|
		startup.wait;
		user_update_listeners.removeAt(owner);
		startup.signal;
	}


	sendMsg { |... args|
		var tag;
		tag = args[0];
		tag = this.tag(tag);
		args[0] = tag;
		//tag.postln;
		args.removeAt(0);
		//(tag ++ args).postln;
		netAddr.sendMsg(tag, *args);
	}

	addResp { |key, func|
		var tag;

		tag = this.tag(key);

		^OSCdef(key.asSymbol, func, tag, recvPort: port)
	}
}



SignedChat {

var win, posts, input, button, oscdef, netManager;


	*new {| netManager|
		//netManager.postln;
		^super.new.init(netManager);
	}

	init {|net|

		var act;

		netManager = net;
		//netManager.postln;

		win = Window.new("Communication", Rect(128, 64, 500, 360));
		win.view.decorator = FlowLayout(win.view.bounds, 10@10);
		win.view.decorator.gap=10@5;

		posts = TextView(win.view,480@300).editable = false;

		posts.hasVerticalScroller = true;
		posts.autohidesScrollers_(true);

		win.view.decorator.nextLine;

		input = TextView(win.view,400@30)
		.focus(true)
		.autohidesScrollers_(true);

		button = Button.new(win.view, 70@30).states_([[">"]]);
		button.action = {
			var blah;
			blah = input.string;
			input.string = "";
			blah = blah.stripWhiteSpace;
			blah = blah.replace(""++13.asAscii, "\\n");
			blah = blah.replace(""++10.asAscii, "\\n");
			netManager.sendMsg("/signedchat", netManager.name, blah); // we can send multiple arguments in an OSC message

		};

		act = input.keyDownAction;
		input.keyDownAction_({ arg view, char, modifiers, unicode, keycode;

			act.value(view, char, modifiers, unicode, keycode);

			(char == 13.asAscii).if({
				button.doAction;
			});
		});

		oscdef = netManager.addResp("/signedchat", {|msg|
			//msg.postln;
			win.isClosed.not.if ({
				msg[2] = msg[2].asString.replace("\\n", "\n");
				AppClock.sched(0, { // we're going to change the GUI, so it's got to be scheduled
					posts.string = posts.string ++ "\n"
					++ msg[1] // Who sent this
					++ "> "
					++ msg[2] // update the string in the post area
				})
			})
		});

		win.onClose_({ oscdef.free; }); // clean up!

		win.front;
	}

}