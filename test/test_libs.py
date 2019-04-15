import libs


def test_get_acl_address():
    actual = libs.get_acl_address('.', 'nile', 'v0.6.10')
    expected = '0x6bd5fdc37b9c87ba73dda230e5dc18e9fda71ff9'
    assert actual == expected


def test_default():
    actual = libs.default_value('', 'hello')
    expected = 'hello'

    assert actual == expected

    actual = libs.default_value([], 'it')
    expected = 'it'
    assert actual == expected
