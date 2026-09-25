// Implicitly imported into every module under app.*
//
// Pulls in both sets of ambient accessors: the shell's (`theme`, `chrome`,
// `preferences`) and this application's (`model`). They never collide, because
// the shell cannot name your model.
//
// Guarded with `#if !macro` because js.* does not exist in macro context, and
// these imports pull browser types in transitively.

#if !macro
import js.Browser.*;

import kit.App;
import kit.Dialog;
import kit.Keys;
import kit.Shortcuts.*;
import kit.platform.Platform;
import kit.platform.Capability;
import kit.ui.*;

import app.Shortcuts.*;

// Uncomment once you have your first component under src/app/ui. A wildcard
// import of a package with no modules in it is a compile error, which is why
// it is not already here.
// import app.ui.*;
#end
