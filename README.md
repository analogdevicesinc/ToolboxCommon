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

Not available with this base: code generation, Simulink and HDL targeting;
`libName`, `useCalllib` and `useCodegen`; `getData` and `sendData`.
