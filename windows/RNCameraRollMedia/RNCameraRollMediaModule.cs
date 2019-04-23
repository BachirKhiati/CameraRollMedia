using ReactNative.Bridge;
using System;
using System.Collections.Generic;
using Windows.ApplicationModel.Core;
using Windows.UI.Core;

namespace Camera.Roll.Media.RNCameraRollMedia
{
    /// <summary>
    /// A module that allows JS to share data.
    /// </summary>
    class RNCameraRollMediaModule : NativeModuleBase
    {
        /// <summary>
        /// Instantiates the <see cref="RNCameraRollMediaModule"/>.
        /// </summary>
        internal RNCameraRollMediaModule()
        {

        }

        /// <summary>
        /// The name of the native module.
        /// </summary>
        public override string Name
        {
            get
            {
                return "RNCameraRollMedia";
            }
        }
    }
}
