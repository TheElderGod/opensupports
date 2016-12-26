describe '/user/get' do
    request('/user/logout')
    Scripts.createUser('user_get@os4.com', 'user_get','User Get')

    Scripts.login('user_get@os4.com', 'user_get')
    result = request('/ticket/create', {
        title: 'Should we pay?',
        content: 'A Lannister always pays his debts.',
        departmentId: 1,
        language: 'en',
        language: 'en',
        csrf_userid: $csrf_userid,
        csrf_token: $csrf_token
    })

    @ticketNumber = result['data']['ticketNumber']

    it 'should fail if not logged' do
        request('/user/logout')
        result = request('/user/get', {
            csrf_userid: $csrf_userid,
            csrf_token: $csrf_token
        })

        (result['status']).should.equal('fail')
    end

    it 'should successfully return the ticket information' do
        result = Scripts.login('user_get@os4.com', 'user_get')
        $csrf_userid = result['userId']
        $csrf_token = result['token']
        result = request('/user/get', {
            csrf_userid: $csrf_userid,
            csrf_token: $csrf_token
        })

        ticket = $database.getRow('ticket', @ticketNumber, 'ticket_number')

        (result['status']).should.equal('success')
        (result['data']['name']).should.equal('User Get')
        (result['data']['email']).should.equal('user_get@os4.com')

        ticketFromUser = result['data']['tickets'][0]
        (ticketFromUser['ticketNumber']).should.equal(ticket['ticket_number'])
        (ticketFromUser['title']).should.equal(ticket['title'])
        (ticketFromUser['content']).should.equal(ticket['content'])
        (ticketFromUser['department']['id']).should.equal('1')
        (ticketFromUser['department']['name']).should.equal($database.getRow('department', 1)['name'])
        (ticketFromUser['date']).should.equal(ticket['date'])
        (ticketFromUser['file']).should.equal(ticket['file'])
        (ticketFromUser['language']).should.equal(ticket['language'])
        (ticketFromUser['unread']).should.equal(false)
        (ticketFromUser['author']['name']).should.equal('User Get')
        (ticketFromUser['author']['email']).should.equal('user_get@os4.com')
        (ticketFromUser['owner']).should.equal(nil)
        (ticketFromUser['events']).should.equal([])
    end
end
