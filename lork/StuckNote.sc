StuckNote {

	var netManager, syn, pd;

	*new {
		^super.new.init();
	}


	init{

		var win, makeFader, myFader, funcs, x, amp;

		netManager = NetworkManager.gui(action: {|net|
			net.postln;
			SignedChat(net);
			win = Window.new("Stuck Note", Rect(128, 64, 500, 360));
			win.view.decorator= FlowLayout(win.view.bounds, 10@10, 10@10);
			syn = Synth(\stuck, [\amp, 0, \x, 0, \gate, 1], Server.default);
			pd = NetAddr.new("127.0.0.1", 5000);

			funcs = [];

			makeFader = { |person, type, me=false|
				var fader, tag;

				me.if({person = net.name});
				tag = "/"++person++"/" ++ type;
				tag = tag.asSymbol;
				//tag.postln;

				fader = EZSlider.new(win.view, 390@20, person + type ++" ", type.asSpec);
				fader.action_({ |ez| //"net".postln;
					me.if({
						syn.set(type, ez.value);// local case
						pd.sendMsg(type, ez.value); // using PD (or other helper)
					});
					net.sendMsg(tag, ez.value) });

				funcs = funcs.add(net.addResp(tag, {|msg|
					me.if({
						syn.set(type, msg[1]); // local case
						pd.sendMsg(type, msg[1]); // using PD (or other helper)
					});
					AppClock.sched(0, {
						fader.value = msg[1];
						nil;
					})
				}));

				fader;
			};

			// set up me
			/*
			myFader = {| type|
				var fader, act;

				type = type.asSymbol;
				fader = makeFader.(net.name, type);

				act = fader.action;
				fader.action = {|ez|
					syn.set(type, ez.value);
					act.value(ez);
				};

				funcs = funcs.add(net.addResp(("/"++net.name++"/"++type).asSymbol), {|msg|
					msg[1].postln;
					syn.set(type, msg[1])
				});
			};*/

			//myFader.('x');
			//myFader.('amp');
			makeFader.(nil, 'x', true);
			makeFader.(nil, 'amp', true);

			net.add_user_update_listener(this, {|person|
				// add faders
				AppClock.sched(0, {
					makeFader.(person, 'x');
					makeFader.(person, 'amp');
					nil;
				});

			});

			win.onClose_({
				{
					syn.set(\gate, 0);
					10.wait;
					syn.free;
				}.fork;

				funcs.do({|responder|
					responder.free
				});
			});

			win.front;
		});
	}

	test {

		netManager.remove_user_update_listener(this);
	}
}