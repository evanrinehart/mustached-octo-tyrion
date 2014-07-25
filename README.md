## Overview

In this system we have Activities, Instances, and Bookings. An activity has
zero or more instances on the schedule, each with its own price, length, and
capacity.  Bookings are associated with an instance. Instances show up as
available if there is still room.

Recurring instances are implemented with a configurable or programmable rule
which generates available instances in the requested range. If someone books
one of the recurring instances then it is saved to the database as a real
instance.

Modifications and cancellations of elements of the schedule never affect
bookings, and so do not affect instances with at least one booking. This may
lead to lockups if later you want to add things back into overlapping places.
In cases where it knows about this conflict ahead of time, the entire operation
is aborted.




## Setup Instructions

`bundle install` to get the gems listed in the Gemfile. It uses sqlite as the
database so you do not need to set up MySQL users or anything.

`rake test` to run the tests of the API.



## API

### Query availability dates

```
GET /activities/{activity_id}/available_days
  ?start_date={yyyy-mm-dd}
  &end_date={yyyy-mm-dd}
```

Responds with a JSON array of dates of availability for the requested activity
within the requested date range. The dates are strings of the form yyyy-mm-dd.


### Query availability times on a day

```
GET /activities/{activity_id}/available_times?date={yyyy-mm-dd}
```

Respond with a JSON array of start times for the activity on that day. The
times are in the form HH:MM:SS.

### Add one activity instance

```
POST /activities/{activity_id}/instances
post body example:
  {
    "date":         "2014-05-04",
    "time":         "13:30:00",
    "minutes_long": 30,
    "price":        40,
    "max_bookings": 9
  }
```

Create a new individual instance for the activity at the specified date and
time. Duration price and capacity must be specified as above. A 400 will happen
if this overlaps an existing instance. Nothing is returned with a 200.

### Install/reinstall recurring activity schedule

```
POST /activities/{activity_id}/schedule/recurring
post body example 1:
  {
    "strategy":"weekly",
    "days":[1,3,5],
    "times":[9,14],
    "price":100,
    "max_bookings":10,
    "minutes_long":90
  }

post body example 2:
  {"strategy":"prime_days"}
```

Install a recurring availability schedule for this activity. Only one recurring
schedule can exist per activity. All unbooked instances will be removed from
the schedule by using this operation. If the process of removing unbooked
instances and then applying this recurring schedule would cause an overlap, a
400 occurs. In case of a 400 nothing happens. On 200 nothing is returned.

The strategy argument determines what other arguments are required. Each would
have it's own documentation. PrimeDays is a toy strategy to demonstrate an
alternative rule: one availability instance occurs on prime numbered days at
7PM (hour 19), and allows no configurability.

### Remove vacant availability instance

```
DELETE /activities/{activity_id}/instances/{instance_id}
```

To specify an instance_id, use the start date and time in the format:
  YYYY-MM-DD_HH:MM:00

Cancel the specified activity instance. 400 will happen if there are any
bookings for that instance. If you cancel a (empty) recurring instance then it
also cancels the entire recurrence schedule, except for currently existing
booked instances.

### Clear entire activity schedule

```
POST /activities/{activity_id}/schedule/clear
```

Cancel all (empty) instances of the specified activity including recurring
ones. No post body is expected. Nothing is returned with a 200.

### Create a booking

```
POST /activities/{activity_id}/instances/{instance_id}/bookings
post body example:
  {"user_id":"u9999"}
```

To specify an instance_id, use the start date and time in the format:
  YYYY-MM-DD_HH:MM:00

Create a new booking for a particular activity instance. 400 will happen
if there is no more room. The user_id must be provided. JSON of the form
{'booking_id':NNNN} will be returned on a 200.

### Cancel a booking

```
DELETE /activities/{activity_id}/instances/{instance_id}/bookings/#{booking_id}
```

To specify an instance_id, use the start date and time in the format:
  YYYY-MM-DD_HH:MM:00

Cancel the specified booking.
