# TODO

* middleware revisit (how to initialize?)
* streaming?
* connection pool?
* X-Method-Override

# BUG

* inheritance should work; assign builder?

# FEATURE

* middleware composer
* headers and payload logs for CommonLogger

# rest-request

* fix DRY by defining `prepare :: env -> env`
* fix TIMER by doing dedicated timeout, instead of using a generic timeout.
  timeout middleware won't work well.
* FAIL and LOG need to be reimplemented as well.
