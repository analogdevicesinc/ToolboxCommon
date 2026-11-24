classdef (Abstract) Debug < adi.common.IIOBase
    % Debug IIO debug attribute function calls
    %   Kept so that classes that list it as a superclass still load.
    %   iio_device_debug_attr_read, which this class defined on
    %   matlabshared.libiio.base, is a member of adi.common.IIOBase: it
    %   returns the number of bytes read (the text and its terminator) and
    %   the text, or a negative status and ''.

end
