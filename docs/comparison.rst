=========================
 Mock Library Comparison
=========================


.. testsetup:: *

    import sys
    import mock
    from flexmock import flexmock
    import mox
    import somemodule
    import dingus

    def assertEqual(a, b):
        assert a == b, ("%r != %r" % (a, b))

    def assertRaises(Exc, func):
        try:
            func()
        except Exc:
            return
        assert False, ("%s not raised" % Exc)

    class SomeException(Exception):
        some_method = method1 = method2 = None
    SomeObject = SomeException
    some_other_object = somemodule.SomeClass()


This is a side-by-side comparison of how to accomplish some basic tasks with
popular Python mocking libraries and frameworks.

The libraries are:

* `mock <http://www.voidspace.org.uk/python/mock/>`_
* `flexmock <http://pypi.python.org/pypi/flexmock>`_
* `mox <http://pypi.python.org/pypi/mox>`_
* `Mocker <http://niemeyer.net/mocker>`_
* `Dingus <http://pypi.python.org/pypi/dingus>`_

Some mocking tools are intentionally omitted: 

* `python-mock <http://python-mock.sourceforge.net/>`_ (last release in 2005)
* `pmock <http://pmock.sourceforge.net/>`_ (last release in 2004 and doesn't import in modern Pythons).

Other mocking frameworks are not yet represented here:

* `MiniMock <http://pypi.python.org/pypi/MiniMock>`_
* `fudge <http://pypi.python.org/pypi/fudge>`_

This comparison is by no means complete, and also may not be fully idiomatic
for all the libraries represented. *Please* contribute corrections and missing
comparisons to the `GitHub project
<https://github.com/garybernhardt/python-mock-comparison>`_. Pull requests are
appreciated.

History of this document:

* Originally created by the `Mox project <https://code.google.com/p/pymox/wiki/MoxComparison>`_
* Extended for `flexmock and mock <http://has207.github.com/flexmock/compare.html>`_ by Herman Sheremetyev
* Further edited for use in the `mock documentation <http://www.voidspace.org.uk/python/mock/compare.html>`_ by Michael Foord
* Generalizd with doctests for all libraries by Gary Bernhardt

.. note::

    Many examples tasks here were originally created by Mox, which is a mocking
    *framework* rather than a *library* like mock or Dingus. Some tasks shown
    naturally exemplify tasks that frameworks are good at and not the ones they
    make harder. In particular you can take a `Mock`, `MagicMock`, or Dingus
    object and use it in any way you want with no up-front configuration.


Simple fake object
~~~~~~~~~~~~~~~~~~

.. testsetup:: simple_fake_object

    from mocker import Mocker
    mocker = Mocker()

.. doctest:: simple_fake_object

    >>> # mock
    >>> my_mock = mock.Mock()
    >>> my_mock.some_method.return_value = "calculated value"
    >>> my_mock.some_attribute = "value"
    >>> assertEqual("calculated value", my_mock.some_method())
    >>> assertEqual("value", my_mock.some_attribute)

    >>> # Flexmock
    >>> some_object = flexmock(some_method=lambda: "calculated value", some_attribute="value")
    >>> assertEqual("calculated value", some_object.some_method())
    >>> assertEqual("value", some_object.some_attribute)

    >>> # Mox
    >>> my_mock = mox.MockAnything()
    >>> my_mock.some_method().AndReturn("calculated value")
    'calculated value'
    >>> my_mock.some_attribute = "value"
    >>> mox.Replay(my_mock)
    >>> assertEqual("calculated value", my_mock.some_method())
    >>> assertEqual("value", my_mock.some_attribute)

    >>> # Mocker
    >>> my_mock = mocker.mock()
    >>> my_mock.some_method()
    <mocker.Mock object at ...>
    >>> mocker.result("calculated value")
    >>> my_mock.some_attribute
    <mocker.Mock object at ...>
    >>> mocker.result("value")
    >>> mocker.replay()
    >>> assertEqual("calculated value", my_mock.some_method())
    >>> assertEqual("value", my_mock.some_attribute)

    >>> # Dingus
    >>> my_dingus = dingus.Dingus(some_attribute="value",
    ...                           some_method__returns="calculated value")
    >>> assertEqual("calculated value", my_dingus.some_method())
    >>> assertEqual("value", my_dingus.some_attribute)


Simple mock
~~~~~~~~~~~

.. testsetup:: simple_mock

    from mocker import Mocker
    mocker = Mocker()

.. doctest:: simple_mock

    >>> # mock
    >>> my_mock = mock.Mock()
    >>> my_mock.some_method.return_value = "value"
    >>> assertEqual("value", my_mock.some_method())
    >>> my_mock.some_method.assert_called_once_with()

    >>> # Flexmock
    >>> some_object = flexmock()
    >>> some_object.should_receive("some_method").and_return("value").once
    <flexmock.Expectation object at ...>
    >>> assertEqual("value", some_object.some_method())

    >>> # Mox
    >>> my_mock = mox.MockAnything()
    >>> my_mock.some_method().AndReturn("value")
    'value'
    >>> mox.Replay(my_mock)
    >>> assertEqual("value", my_mock.some_method())
    >>> mox.Verify(my_mock)

    >>> # Mocker
    >>> my_mock = mocker.mock()
    >>> my_mock.some_method()
    <mocker.Mock object at ...>
    >>> mocker.result("value")
    >>> mocker.replay()
    >>> assertEqual("value", my_mock.some_method())
    >>> mocker.verify()

    >>> # Dingus
    >>> my_dingus = dingus.Dingus(some_method__returns="value")
    >>> assertEqual("value", my_dingus.some_method())
    >>> assert my_dingus.some_method.calls().once()


Creating partial mocks
~~~~~~~~~~~~~~~~~~~~~~

.. testsetup:: creating_partial_mocks

    from mocker import Mocker
    mocker = Mocker()

.. doctest:: creating_partial_mocks

    >>> # mock
    >>> my_mock = mock.Mock(spec=SomeObject)
    >>> my_mock.some_method.return_value = "value"
    >>> assertEqual("value", my_mock.some_method())

    >>> # Flexmock
    >>> flexmock(SomeObject).should_receive("some_method").and_return('value')
    <flexmock.Expectation object at ...>
    >>> assertEqual("value", SomeObject().some_method())

    >>> # Mox
    >>> my_mock = mox.MockObject(SomeObject)
    >>> my_mock.some_method().AndReturn("value")
    'value'
    >>> mox.Replay(my_mock)
    >>> assertEqual("value", my_mock.some_method())
    >>> mox.Verify(my_mock)

    >>> # Mocker
    >>> some_object = somemodule.SomeClass()
    >>> my_mock = mocker.proxy(some_object)
    >>> my_mock.Get()
    <mocker.Mock object at ...>
    >>> mocker.result("value")
    >>> mocker.replay()
    >>> assertEqual("value", my_mock.Get())
    >>> mocker.verify()

    >>> # Dingus
    >>> object = SomeObject
    >>> object.some_method = dingus.Dingus(return_value="value")
    >>> assertEqual("value", object.some_method())


Ensure calls are made in specific order
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. testsetup:: calls_in_specific_order

    from mocker import Mocker
    mocker = Mocker()

.. doctest:: calls_in_specific_order

    >>> # mock
    >>> my_mock = mock.Mock(spec=SomeObject)
    >>> my_mock.method1()
    <mock.Mock object at 0x...>
    >>> my_mock.method2()
    <mock.Mock object at 0x...>
    >>> assertEqual(my_mock.method_calls, [('method1',), ('method2',)])

    >>> # Flexmock
    >>> some_object = flexmock(SomeObject)
    >>> some_object.should_receive('method1').once.ordered.and_return('first thing')
    <flexmock.Expectation object at ...>
    >>> some_object.should_receive('method2').once.ordered.and_return('second thing')
    <flexmock.Expectation object at ...>

    >>> # Mox
    >>> my_mock = mox.MockObject(SomeObject)
    >>> my_mock.method1().AndReturn('first thing')
    'first thing'
    >>> my_mock.method2().AndReturn('second thing')
    'second thing'
    >>> mox.Replay(my_mock)
    >>> my_mock.method1()
    'first thing'
    >>> my_mock.method2()
    'second thing'
    >>> mox.Verify(my_mock)

    >>> # Mocker
    >>> my_mock = mocker.mock()
    >>> with mocker.order():
    ...     my_mock.method1()
    ...     mocker.result('first thing')
    ...     my_mock.method2()
    ...     mocker.result('second thing')
    ...     mocker.replay()
    ...     my_mock.method1()
    ...     my_mock.method2()
    ...     mocker.verify()
    <mocker.Mock object at ...>
    <mocker.Mock object at ...>
    'first thing'
    'second thing'

    >>> # Dingus
    >>> my_dingus = dingus.Dingus()
    >>> my_dingus.method1()
    <Dingus ...>
    >>> my_dingus.method2()
    <Dingus ...>
    >>> assertEqual(['method1', 'method2'], [call.name for call in my_dingus.calls])


Raising exceptions
~~~~~~~~~~~~~~~~~~

.. testsetup:: raising_exceptions

    from mocker import Mocker
    mocker = Mocker()

.. doctest:: raising_exceptions

    >>> # mock
    >>> my_mock = mock.Mock()
    >>> my_mock.some_method.side_effect = SomeException("message")
    >>> assertRaises(SomeException, my_mock.some_method)

    >>> # Flexmock
    >>> some_object = flexmock()
    >>> some_object.should_receive("some_method").and_raise(SomeException("message"))
    <flexmock.Expectation object at ...>
    >>> assertRaises(SomeException, some_object.some_method)

    >>> # Mox
    >>> my_mock = mox.MockAnything()
    >>> my_mock.some_method().AndRaise(SomeException("message"))
    >>> mox.Replay(my_mock)
    >>> assertRaises(SomeException, my_mock.some_method)
    >>> mox.Verify(my_mock)

    >>> # Mocker
    >>> my_mock = mocker.mock()
    >>> my_mock.some_method()
    <mocker.Mock object at ...>
    >>> mocker.throw(SomeException("message"))
    >>> mocker.replay()
    >>> assertRaises(SomeException, my_mock.some_method)
    >>> mocker.verify()

    >>> # Dingus
    >>> my_dingus = dingus.Dingus()
    >>> my_dingus.some_method = dingus.exception_raiser(SomeException)
    >>> assertRaises(SomeException, my_dingus.some_method)


Override new instances of a class
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. doctest::

    >>> # mock
    >>> with mock.patch('somemodule.SomeClass') as MockClass:
    ...     MockClass.return_value = some_other_object
    ...     assertEqual(some_other_object, somemodule.SomeClass())
    ...

    >>> # Flexmock
    >>> flexmock(somemodule.SomeClass, new_instances=some_other_object)
    <flexmock.UnittestFlexMock object at ...>
    >>> assertEqual(some_other_object, somemodule.SomeClass())

    # >>> # Mox
    # >>> # XXX FAILING
    # >>> # (you will probably have mox.Mox() available as self.mox in a real test)
    # >>> mox.Mox().StubOutWithMock(somemodule, 'SomeClass', use_mock_anything=True)
    # >>> somemodule.SomeClass().AndReturn(some_other_object)
    # >>> mox.ReplayAll()
    # >>> assertEqual(some_other_object, somemodule.SomeClass())

    >>> # Mocker
    >>> # (TODO)

    >>> # Dingus
    >>> MockClass = dingus.Dingus(return_value=some_other_object)
    >>> with dingus.patch('somemodule.SomeClass', MockClass):
    ...     assertEqual(some_other_object, somemodule.SomeClass())


Call the same method multiple times
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

    You don't need to do *any* configuration to call `mock.Mock()` methods
    multiple times. Attributes like `call_count`, `call_args_list` and
    `method_calls` provide various different ways of making assertions about
    how the mock was used.

.. doctest::

    >>> # mock
    >>> my_mock = mock.Mock()
    >>> my_mock.some_method()
    <mock.Mock object at 0x...>
    >>> my_mock.some_method()
    <mock.Mock object at 0x...>
    >>> assert my_mock.some_method.call_count >= 2

    >>> # Flexmock (verifies that the method gets called at least twice)
    >>> some_object = flexmock()
    >>> flexmock(some_object).should_receive('some_method').at_least.twice
    <flexmock.Expectation object at ...>

    >>> # Mox
    >>> # (does not support variable number of calls, so you need to create a new entry for each explicit call)
    >>> my_mock = mox.MockObject(some_object)
    >>> my_mock.some_method(mox.IgnoreArg(), mox.IgnoreArg())
    <mox.MockMethod object at ...>
    >>> my_mock.some_method(mox.IgnoreArg(), mox.IgnoreArg())
    <mox.MockMethod object at ...>
    >>> mox.Replay(my_mock)
    >>> my_mock.some_method(some_object, some_object)
    >>> my_mock.some_method(some_object, some_object)
    >>> mox.Verify(my_mock)

    >>> # Mocker
    >>> # (TODO)

    >>> # Dingus
    >>> my_dingus = dingus.Dingus()
    >>> my_dingus.some_method()
    <Dingus ...>
    >>> my_dingus.some_method()
    <Dingus ...>
    >>> assert len(my_dingus.calls('some_method')) == 2


Mock chained methods
~~~~~~~~~~~~~~~~~~~~

.. doctest::

    >>> # mock
    >>> my_mock = mock.Mock()
    >>> method3 = my_mock.method1.return_value.method2.return_value.method3
    >>> method3.return_value = 'some value'
    >>> assertEqual('some value', my_mock.method1().method2().method3(1, 2))
    >>> method3.assert_called_once_with(1, 2)

    >>> # Flexmock
    >>> # (intermediate method calls are automatically assigned to temporary fake objects
    >>> # and can be called with any arguments)
    >>> arg1, arg2 = 'arg1', 'arg2'
    >>> flexmock(some_object).should_receive(
    ...     'method1.method2.method3'
    ... ).with_args(arg1, arg2).and_return('some value')
    <flexmock.Expectation object at ...>
    >>> assertEqual('some value', some_object.method1().method2().method3(arg1, arg2))

    # >>> # Mox
    # >>> # XXX FAILING
    # >>> some_object = somemodule.SomeClass()
    # >>> my_mock = mox.MockObject(some_object)
    # >>> my_mock2 = mox.MockAnything()
    # >>> my_mock3 = mox.MockAnything()
    # >>> my_mock.method1().AndReturn(my_mock)
    # <MockAnything instance>
    # >>> my_mock2.method2().AndReturn(my_mock2)
    # <MockAnything instance>
    # >>> my_mock3.method3(arg1, arg2).AndReturn('some_value')
    # 'some_value'
    # >>> mox.Mox().ReplayAll()
    # >>> assertEqual("some_value", some_object.method1().method2().method3(arg1, arg2))
    # >>> self.mox.VerifyAll()

    >>> # Mocker
    >>> # (TODO)

    >>> # Dingus
    >>> my_dingus = dingus.Dingus()
    >>> method3 = my_dingus.method1.return_value.method2.return_value.method3
    >>> method3.return_value = 'some value'
    >>> assertEqual('some value', my_dingus.method1().method2().method3(1, 2))
    >>> assert method3.calls('()', 1, 2).once()


Mocking a context manager
~~~~~~~~~~~~~~~~~~~~~~~~~

Examples for mock and Dingus only (so far):

.. doctest::

    >>> # mock
    >>> my_mock = mock.MagicMock()
    >>> with my_mock:
    ...     pass
    ...
    >>> my_mock.__enter__.assert_called_with()
    >>> my_mock.__exit__.assert_called_with(None, None, None)

    >>> # Dingus (nothing special here; all dinguses are "magic mocks")
    >>> my_dingus = dingus.Dingus()
    >>> with my_dingus:
    ...     pass
    ...
    >>> assert my_dingus.__enter__.calls()
    >>> assert my_dingus.__exit__.calls('()', None, None, None)


Mocking the builtin open used as a context manager
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Examples for mock and Dingus only (so far):

.. doctest::

    >>> # mock
    >>> my_mock = mock.MagicMock()
    >>> with mock.patch('__builtin__.open', my_mock):
    ...     manager = my_mock.return_value.__enter__.return_value
    ...     manager.read.return_value = 'some data'
    ...     with open('foo') as h:
    ...         data = h.read()
    ...
    >>> data
    'some data'
    >>> my_mock.assert_called_once_with('foo')

    >>> # mock (alternate)
    >>> with mock.patch('__builtin__.open') as my_mock:
    ...     my_mock.return_value.__enter__ = lambda s: s
    ...     my_mock.return_value.__exit__ = mock.Mock()
    ...     my_mock.return_value.read.return_value = 'some data'
    ...     with open('foo') as h:
    ...         data = h.read()
    ...
    >>> data
    'some data'
    >>> my_mock.assert_called_once_with('foo')

    >>> # Dingus
    >>> my_dingus = dingus.Dingus()
    >>> with dingus.patch('__builtin__.open', my_dingus):
    ...     file_ = open.return_value.__enter__.return_value
    ...     file_.read.return_value = 'some data'
    ...     with open('foo') as h:
    ...         data = f.read()
    ...
    >>> data
    'some data'
    >>> assert my_dingus.calls('()', 'foo').once()

