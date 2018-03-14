package de.delmak.fussballtipp.persistence;

import de.delmak.fussballtipp.UserSession;
import java.util.List;

public class Bet extends HibernateObject
{

	public static final String BETKIND_MATCH = "MATCH";
	public static final String BETKIND_BRACKETWINNER = "BRACKETWINNER";
	public static final String BETKIND_CHAMPION = "CHAMPION";
	
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

	private String betkind;

	public String getBetkind()
	{
		return betkind;
	}

	public void setBetkind(String betkind)
	{
		this.betkind = betkind;
	}

	private Integer matchId;

	public Integer getMatchId()
	{
		return matchId;
	}

	public void setMatchId(Integer matchId)
	{
		this.matchId = matchId;
	}

	private Integer scoreHome;

	public Integer getScoreHome()
	{
		return scoreHome;
	}

	public void setScoreHome(Integer scoreHome)
	{
		this.scoreHome = scoreHome;
	}

	private Integer scoreGuest;

	public Integer getScoreGuest()
	{
		return scoreGuest;
	}

	public void setScoreGuest(Integer scoreGuest)
	{
		this.scoreGuest = scoreGuest;
	}

	private Team team;

	public Team getTeam()
	{
		return team;
	}

	public void setTeam(Team team)
	{
		this.team = team;
	}

	private Integer bracketId;

	public Integer getBracketId()
	{
		return bracketId;
	}

	public void setBracketId(Integer bracketId)
	{
		this.bracketId = bracketId;
	}

	public Boolean getCanPlaceBet()
	{
		if (getBetkind().equals(BETKIND_MATCH) == true)
		{
			Match match = Match.getById(getMatchId());
			
			return (match.getIsOpenForBets() == true);
		}
		else
		if (getBetkind().equals(BETKIND_BRACKETWINNER) == true)
		{
			Bracket bracket = Bracket.getById(getBracketId());
			
			return (bracket.getIsOpenForBets() == true);
		}
		else
		if (getBetkind().equals(BETKIND_CHAMPION) == true);
		{
			Phase phase = Phase.getByName("Achtel");
			
			return (phase.getIsOpenForBets() == true);
		}
	}
	
	@Override
	public String toString()
	{
		return String.format("%s_%s_%s_%s_%s", getClass().getName(), getUser().getUserId(), getBetkind(), getMatchId(), getBracketId());
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
	
	public static void insert(Bet object)
	{
		try
		{
			beginTransaction();
			getSession().save(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static void modify(Bet object)
	{
		try
		{
			beginTransaction();
			getSession().update(object);
			commitTransaction();
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static Bet getById(int id)
	{
		try
		{
			beginTransaction();
			
			Bet result = (Bet) getSession()
					.getNamedQuery("getBetById")
					.setInteger("id", id)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}	
	
	public static Bet getByUserAndBetKindAndMatchId(Integer userId, String betkind, Integer matchId)
	{
		try
		{
			beginTransaction();
			
			Bet result = (Bet) getSession()
					.getNamedQuery("getBetByUserAndBetKindAndMatchId")
					.setInteger("userId", userId)
					.setString("betkind", betkind)
					.setInteger("matchId", matchId)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}	
	
	public static Bet getByUserAndBetKindAndBracketId(Integer userId, String betkind, Integer bracketId)
	{
		try
		{
			beginTransaction();
			
			Bet result = (Bet) getSession()
					.getNamedQuery("getBetByUserAndBetKindAndBracketId")
					.setInteger("userId", userId)
					.setString("betkind", betkind)
					.setInteger("bracketId", bracketId)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}	
	
	public static Bet getByUserAndBetKind(Integer userId, String betkind)
	{
		try
		{
			beginTransaction();
			
			Bet result = (Bet) getSession()
					.getNamedQuery("getBetByUserAndBetKind")
					.setInteger("userId", userId)
					.setString("betkind", betkind)
					.uniqueResult();
			
			commitTransaction();
			
			return result;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}	
	
	public static List getListByBetKindAndMatchId(String betkind, Integer matchId, List userIds)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getBetsByBetKindAndMatchId")
					.setString("betkind", betkind)
					.setInteger("matchId", matchId)
					.setParameterList("userIds", userIds)
					.list();
			
			commitTransaction();
			
			return resultRows;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}	
	
	public static List getListByBetKindAndBracketId(String betkind, Integer bracketId, List userIds)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getBetsByBetKindAndBracketId")
					.setString("betkind", betkind)
					.setInteger("bracketId", bracketId)
					.setParameterList("userIds", userIds)
					.list();
			
			commitTransaction();
			
			return resultRows;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}	
	
	public static List getListByBetKind(String betkind, List userIds)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getBetsByBetKind")
					.setString("betkind", betkind)
					.setParameterList("userIds", userIds)
					.list();
			
			commitTransaction();
			
			return resultRows;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}	
	
	public static List getListByUserId(Integer userId)
	{
		try
		{
			beginTransaction();
			
			List resultRows = getSession()
					.getNamedQuery("getBetsByUserId")
					.setInteger("userId", userId)
					.list();
			
			commitTransaction();
			
			return resultRows;
		}	
		catch (Exception ex)
		{
			rollbackTransaction();
			throw ex;
		}
	}
	
	public static Bet findByUserAndBetKindAndMatchId(List list, User user, String betkind, Integer matchId)
	{
		Bet betFind = new Bet();
		betFind.setUser(user);
		betFind.setBetkind(betkind);
		betFind.setMatchId(matchId);

		Integer idx = list.indexOf(betFind);
		Bet bet = null;

		if (idx >= 0)
		{
			bet = (Bet) list.get(idx);
		}

		return bet;
	}

	public static Bet findByUserAndBetKindAndBracketId(List list, User user, String betkind, Integer bracketId)
	{
		Bet betFind = new Bet();
		betFind.setUser(user);
		betFind.setBetkind(betkind);
		betFind.setBracketId(bracketId);

		Integer idx = list.indexOf(betFind);
		Bet bet = null;

		if (idx >= 0)
		{
			bet = (Bet) list.get(idx);
		}

		return bet;
	}

	public static Bet findByUserAndBetKind(List list, User user, String betkind)
	{
		Bet betFind = new Bet();
		betFind.setUser(user);
		betFind.setBetkind(betkind);

		Integer idx = list.indexOf(betFind);
		Bet bet = null;

		if (idx >= 0)
		{
			bet = (Bet) list.get(idx);
		}

		return bet;
	}
}
