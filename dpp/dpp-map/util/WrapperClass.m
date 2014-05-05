% Defines a class to hold "value".  Useful for doing pass-by-reference.
classdef WrapperClass < handle
  properties
    value = [];
  end
  methods
    function obj = WrapperClass()
    end
  end
end