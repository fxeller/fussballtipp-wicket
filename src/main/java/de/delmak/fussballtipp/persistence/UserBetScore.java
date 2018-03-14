package de.delmak.fussballtipp.persistence;

public class UserBetScore extends HibernateObject
{

	private Integer userId;

	public Integer getUserId()
	{
		return userId;
	}

	public void setUserId(Integer userId)
	{
		this.userId = userId;
	}

	private Integer betId;

	public Integer getBetId()
	{
		return betId;
	}

	public void setBetId(Integer betId)
	{
		this.betId = betId;
	}

	private User user;

	public User getUser()
	{
		return user;
	}

	public void setUser(User user)
	{
		this.user = user;
	}

	private Bet bet;

	public Bet getBet()
	{
		return bet;
	}

	public void setBet(Bet bet)
	{
		this.bet = bet;
	}

	private Integer score;

	public Integer getScore()
	{
		return score;
	}

	public void setScore(Integer score)
	{
		this.score = score;
	}

	@Override
	public String toString()
	{
		return String.format("%s_%s_%s", getClass().getName(), getUser().getUserId(), getBet().getBetId());
	}
	
	@Override
	public boolean equals(Object obj)
	{
		return obj.toString().equals(toString());				
	}

	@Override
	public int hashCode()
	{
		return toString().hashCode();
	}

}
