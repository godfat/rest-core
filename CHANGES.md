# rest-core CHANGES

## rest-core 0.2.1 -- 2011-08-25

* [twitter] Fixed default site
* [twitter] Now Twitter#tweet accepts a 2nd argument to upload an image
* [oauth1_header] Fixed a bug for multipart posting. Since Rails' uploaded
                  file is not an IO object, so we can't only test against
                  IO object, but also read method.

## rest-core 0.2.0 -- 2011-08-24

* First serious release!
