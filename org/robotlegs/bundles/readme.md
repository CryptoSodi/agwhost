# Robotlegs Bundles

A selection of built-in bundles.

## Bundles Vs Extensions

An extension integrates a single utility or library into a Robotlegs context.

A bundle bundles up a selection of extensions and configurations into a single drop-in package.

## Creating a Bundle

A bundle implements the IExtension interface. When included into a context, that context is immediately passed through to the extend() method.

    package org.robotlegs.bender.bundles.superDuper
    {
      public class SuperDuperBundle implements IExtension
      {
        public function extend(context:IContext):void
        {
          context.extend(
            SuperDuperExtensionA,
            SuperDuperExtensionB,
            SuperDuperExtensionC);
        }
      }
    }

NOTE: The context instance passed to extend() may not be fully initialized.

A bundle should do little more than include required extensions.

