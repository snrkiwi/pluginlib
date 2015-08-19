#ifndef __pluginlib__test_base__h__
#define __pluginlib__test_base__h__

namespace test_base
{

class Fubar
{
public:
  virtual ~Fubar()
  {}
  virtual void initialize(double foo) = 0;
  virtual double result() = 0;

protected:
  Fubar()
  {}
};

};  // namespace test_base

#endif  // __pluginlib__test_base__h__
