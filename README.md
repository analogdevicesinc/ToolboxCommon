# ToolboxCommon
Common components shared across MATLAB toolboxes

## libiio

The classes are built on `adi.common.IIOBase`, which uses the libiio v1 MATLAB
bindings (package `iio` of [libiio-conv](https://github.com/tfcollins/libiio-conv)).
The folder `matlab` of a libiio-conv checkout in which the MEX file was built
must be on the MATLAB path.

`IIOBase` replaces `matlabshared.libiio.base` (libiio v0 through `calllib`) and
keeps the member names the device classes call: `getDev`, `getChan`, `cstatus`,
`cPtrCheck`, the `iio_*` wrappers with their status return values,
`enableChannel`, `createBuf`, `destroyBuf`. What was a pointer is an object of
the package `iio` (`iio.Device`, `iio.Channel`), and an empty array where the
pointer was NULL.

Data moves through one `iio.RxStream` or `iio.TxStream` per object
(`readFrame`, `writeFrame`), which converts a whole frame in one call. A class
states the format of its frames in `getStreamFormat`.

`DataTimeout` (seconds) is the `Timeout` of the stream. A finite, positive
value (the default is 5) makes the stream wait with non-blocking dequeues 1 ms
apart; 0 and `Inf` give one blocking dequeue bounded by the timeout of the
context, so `Inf` is not an infinite wait as it was documented for
`matlabshared.libiio.base`.

An error raised by `cstatus` has the identifier `adi:iio:status`. When a call
of the bindings failed in the same operation its message is added, with what
failed: `(status -22; last libiio error, write of frequency: ...)`.

`adi.common.Debug` is kept as an empty class on `IIOBase`, which has its
`iio_device_debug_attr_read`. `adi.common.JESD204` and `getDebugAttributeRAW`
need nothing else. The helpers of `Channel`, `DeviceAttribute` and `BufferADI`
have `Access = ?handle`, as on ToolboxCommon master.

`adi.common.Tx` hands the frame to the stream, which rounds and saturates at
the limits of the storage word of the channel; it makes no cast to
`dataTypeStr`.

Not available with this base: code generation, Simulink and HDL targeting;
`libName`, `useCalllib` and `useCodegen`; `getData` and `sendData`.
