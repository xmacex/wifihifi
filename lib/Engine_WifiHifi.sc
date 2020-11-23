Engine_WifiHifi : CroneEngine {
  var <synth;

  *new { arg context, doneCallback;
	^super.new(context, doneCallback);
  }

  alloc {
	SynthDef(\wifiHifi, {
	  |freq=220, mod_freq=0, mod_depth=0.1, mul=0.25, out=0|
	  var sig, mod;

	  mod = SinOsc.ar(mod_freq, 0, mod_depth);
	  sig = SinOsc.ar(freq)!2;
	  sig = sig * mod;
	  sig = sig * mul;

	  Out.ar(out, sig.softclip);
	}).add;

	context.server.sync;

	synth = Synth.new(\wifiHifi, [
	  \out, context.out_b.index],
	context.xg);

	this.addCommand(\freq, 'f', {|msg|
	  msg.postln;
	  synth.set(\freq, msg[1]);
	});

	this.addCommand(\mod, 'f', {|msg|
	  msg.postln;
	  synth.set(\mod_freq, msg[1] * 33);
	});

	this.addCommand(\mod_depth, 'f', {|msg|
	  msg.postln;
	  synth.set(\mod_depth, msg[1] * 10);
	});
  }

  free {
	synth.free;
  }
}