#ifndef __pluginlib__test_plugins__h__
#define __pluginlib__test_plugins__h__

#include <cmath>

#include "test_base.h"

namespace test_plugins
{
class Bar : public test_base::Fubar
{
public:
  Bar()
  {}

  void initialize(double foo)
  {
    foo_ = foo;
  }

  double result()
  {
    return 0.5 * foo_ * getBar();
  }

  double getBar()
  {
    return sqrt((foo_ * foo_) - ((foo_ / 2) * (foo_ / 2)));
  }

private:
  double foo_;
};

class Foo : public test_base::Fubar
{
public:
  Foo()
  {}

  void initialize(double foo)
  {
    foo_ = foo;
  }

  double result()
  {
    return foo_ * foo_;
  }

private:
  double foo_;

};

};  // namespace test_plugins

#endif  // __pluginlib__test_plugins__h__
